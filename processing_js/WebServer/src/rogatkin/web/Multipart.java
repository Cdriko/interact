/* tjws - Multipart.java
 * Copyright (C) 1999-2010 Dmitriy Rogatkin.  All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
 *  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *  $Id: Multipart.java,v 1.4 2010/05/22 05:14:53 dmitriy Exp $
 * Created on May 17, 2010
 */

package rogatkin.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;

import javax.servlet.ServletInputStream;
import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.Part;

import Acme.Utils;
import Acme.Serve.Serve;
import rogatkin.web.WebAppServlet.ServletAccessDescr;

public class Multipart {

	private LinkedList<PartImpl> parts;

	private boolean tooLarge;

	private IOException ioException;

	Multipart(ServletRequest request, String boundary, ServletAccessDescr sad) {
		try {
			String scl = ((HttpServletRequest) request).getHeader("content-length");
			long contentLength = -1;
			if (scl != null)
				try {
					contentLength = Long.parseLong(scl);
				} catch (NumberFormatException nfe) {
				}
			if (contentLength > 0 && sad.multipartMaxRequest > 0 && sad.multipartMaxRequest < contentLength)
				throw new IOException(String.format("Request size %d is bigger than limited by %d", contentLength,
						sad.multipartMaxRequest));
			String encoding = request.getCharacterEncoding(); // TODO request.getLocale(); and calculate encoding
			if (encoding == null)
				encoding = Serve.UTF8;
			ServletInputStream sis = request.getInputStream();

			parts = new LinkedList<PartImpl>();
			long bytesRead = 0;
			parts_loop: do {
				// read part 				
				PartImpl pi = new PartImpl();
				long partSize = pi.readPart(encoding, boundary, sis, 0, sad);
				if (partSize < 0) 
					bytesRead -= partSize;					
				 else 
					 bytesRead += partSize;
				if ((sad.multipartMaxFile > 0 && pi.fileSize > sad.multipartMaxFile)
						|| (sad.multipartMaxRequest > 0 && sad.multipartMaxRequest > bytesRead))
					tooLarge = true;
				else
					parts.add(pi);
				if (partSize < 0)
					break;
			} while (tooLarge == false && (contentLength < 0 || contentLength > 0 && bytesRead < contentLength));
		} catch (IOException ioe) {
			ioException = ioe;
		}
	}

	LinkedList<PartImpl> getParts() throws IOException {
		if (ioException != null)
			throw ioException;
		if (tooLarge)
			throw new IllegalStateException("Request or its parts too large");
		return parts;
	}

	Part getPart(String n) throws IOException {
		if (ioException != null)
			throw ioException;
		if (tooLarge)
			throw new IllegalStateException("Request or its parts too large");
		for (Part p : parts)
			if (n.equals(p.getName()))
				return p;
		return null;
	}

	static class PartImpl implements Part {
		HashMap<String, String> headers = new HashMap<String, String>(6);

		ByteArrayOutputStream cos = new ByteArrayOutputStream(1024 * 4);

		String name;

		File partFile;

		long fileSize;

		private final static int no_rn = 1;

		private final static int last_r = 2;

		private final static int last_rn = 3;

		long readPart(String encoding, String boundary, ServletInputStream sis, long currentPos, ServletAccessDescr sad)
				throws IOException {

			byte[] buff = new byte[8 * 1024];
			int boundaryLen = boundary.length();
			if (boundaryLen >= (buff.length - 2))
				throw new IOException("Boundary length exceeds allowed:" + boundaryLen+"/"+(buff.length-2));
			String hl;
			int ss;
			// parse part headers
			do {
				int len = sis.readLine(buff, 0, buff.length);
				if (len < 0)
					throw new IOException("Trying reading parts after EOS");
				currentPos += len;
				if (buff[len - 1] != '\n')
					throw new IOException("Part header is over " + buff.length);				
				hl = new String(buff, 0, len - 2);
				//System.err.println("h:" + hl);
				if (hl.isEmpty())
					break;
				ss = hl.indexOf(boundary);
				if (ss >= 0) {
					if (hl.indexOf("--", boundaryLen+ss) == boundaryLen+ss)
						return -currentPos; //
					continue; // 1st part starts with it
				}
					 
				hl = new String(buff, 0, len - 2, encoding);
				ss = hl.indexOf(':');
				if (ss < 0)
					throw new IOException("Illegal multipart header, no value separator ':' in " + hl);
				String header = hl.substring(0, ss).toLowerCase();
				String value = hl.substring(ss + 1).trim();
				headers.put(header, value);
				if (header.equals("Content-Disposition".toLowerCase())) {
					// TODO add real parser as for cookies
					if (name != null)
						throw new IOException("Multiple header 'Content-Disposition' for the same part: "+hl); 
					int ni = value.toLowerCase().indexOf("name=\"");
					if (ni < 0)
						throw new IOException("Part name is missed in 'Content-Disposition'" + hl);
					int eq = value.indexOf('"', ni + "name=\"".length());
					name = value.substring(ni + "name=\"".length(), eq);
				}
			} while (true);
			// read part content
			fileSize = 0;
			boolean writingInMem = sad.multipartThreshold > 0;
			OutputStream wos = cos;
			int state = no_rn;

			try {
				read_part: do {
					int len = sis.readLine(buff, 0, buff.length);
					if (len < 0)
						throw new IOException("Unexpected end of multipart data");
					//System.err.println("" + len + "==" + new String(buff, 0, len));
					currentPos += len;

					switch (state) {
					case no_rn:
						if (buff[len - 1] == '\n') {
							if (len > 1)
								if (buff[len - 2] == '\r') {
									wos.write(buff, 0, len - 2);
									fileSize += len - 2;
									state = last_rn;
									break;
								}
						} else if (buff[len - 1] == '\r') {
							wos.write(buff, 0, len - 1);
							fileSize += len - 1;
							state = last_r;
							break;
						}
						wos.write(buff, 0, len);
						fileSize += len;

						break;
					case last_r:
						if (buff[len - 1] == '\n') {
							if (len == 1) {
								state = last_rn;
								break;
							}
							wos.write('\r');
							fileSize++;
							if (buff[len - 2] == '\r') {
								wos.write(buff, 0, len - 2);
								fileSize += len - 2;
								state = last_rn;
								break;
							}
						} else if (buff[len - 1] == '\r') {
							wos.write('\r');
							fileSize++;
							wos.write(buff, 0, len - 1);
							fileSize += len - 1;
							state = last_r;
							break;
						}
						wos.write(buff, 0, len);
						fileSize += len;
						state = no_rn;
						break;
					case last_rn:
						if (buff[len - 1] == '\n') {
							if (len > 1)
								if (buff[len - 2] == '\r') {
									hl = new String(buff, 0, len - 2);
									ss = hl.indexOf(boundary);
									if (ss >= 0) {
										if (hl.indexOf("--", ss + boundaryLen) == (ss + boundaryLen))
											return -currentPos;
										else
											break read_part;
									} else {
										wos.write('\r');
										fileSize++;
										wos.write('\n');
										fileSize++;
										wos.write(buff, 0, len - 2);
										fileSize += len - 2;
										break;
									}
								}
						} else if (buff[len - 1] == '\r') { // can't be boundary limiter since buffer is bigger than boundary

						}
						wos.write('\r');
						fileSize++;
						wos.write('\n');
						fileSize++;
						wos.write(buff, 0, len);
						fileSize += len;
						state = no_rn;
						break;
					default:
						throw new IllegalStateException();
					}
					if (sad.multipartMaxFile > 0 && sad.multipartMaxFile <= fileSize)
						throw new IOException("File size exceeds limit of " + sad.multipartMaxFile);
					if (writingInMem && sad.multipartThreshold < fileSize) {
						if (sad.multipartLocation == null || sad.multipartLocation.getName().isEmpty())
							partFile = File.createTempFile(name, "multipart");
						else
							partFile = File.createTempFile(name, "multipart", sad.multipartLocation);
						FileOutputStream fos = new FileOutputStream(partFile);
						fos.write(cos.toByteArray());
						cos.close();
						cos = null;
						wos = fos;
						writingInMem = false;
					}
				} while (true); // TODO add condition	
			} finally {
				if (wos != null) { // can b e null ?
					try {
						wos.close();
					} catch (Exception e) {
					}
				}
			}
			return currentPos;
		}

		@Override
		public void delete() throws IOException {
			if (cos != null) {
				cos.close();
				cos = null;
			}
			if (partFile != null)
				if (partFile.delete() == false)
					throw new IOException("Can't delete part:" + partFile);
		}

		@Override
		public String getContentType() {
			return getHeader("content-type");
		}

		@Override
		public String getHeader(String header) {
			return headers.get(header.toLowerCase());
		}

		@Override
		public Collection<String> getHeaderNames() {
			return headers.keySet();
		}

		@Override
		public Collection<String> getHeaders(String header) {
			LinkedList<String> result = new LinkedList<String>();
			if (getHeader(header) != null)
				result.add(getHeader(header));
			return result;
		}

		@Override
		public InputStream getInputStream() throws IOException {
			if (cos != null)
				return new ByteArrayInputStream(cos.toByteArray());
			else
				return new FileInputStream(partFile);
		}

		@Override
		public String getName() {
			return name;
		}

		@Override
		public long getSize() {
			if (cos != null)
				return cos.size();
			return partFile.length();
		}

		@Override
		public void write(String file) throws IOException {
			if (cos != null) {
				FileOutputStream fos = new FileOutputStream(file);
				fos.write(cos.toByteArray());
				fos.close();
			} else {
				File targetFile = new File(file);
				if (targetFile.exists())
					targetFile.delete();
				if (partFile.renameTo(targetFile) == false) {
					FileInputStream in = null;
					FileOutputStream out = null;
					try {
						Utils.copyStream(in = new FileInputStream(partFile), out = new FileOutputStream(targetFile), 0);
					} catch (IOException ioe) {
						throw new IOException("Can't move or move file " + partFile + " to " + file);
					} finally {
						if (in != null)
							try {
								in.close();
							} catch (IOException e) {

							}
						if (out != null)
							try {
								out.close();
							} catch (IOException e) {

							}
					}
				} else
					partFile = targetFile;
			}
		}

		@Override
		public String toString() {
			return "Part " + name + ":" + (cos != null ? cos.toString() : partFile);
		}
	}
}
