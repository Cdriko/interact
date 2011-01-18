/**
 * Processing specific wrapper/bridge for using PImage instances with
 * the ZXing decoder. This is done by implementing the required methods
 * defined by ZXing's MonochromeBitmapSource interface. The majority has
 * been taken directly from an earlier implementation (0.2.5) in the ZXing
 * core and then updated to stay compatible with the latest version. 
 *
 * @author Karsten Schmidt <info at postspectacular dot com>
 * 
 * This demo is copyright 2008-2009 Karsten Schmidt.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
class PImageMonochromeBitmapSource implements MonochromeBitmapSource {

  private final int[] pixels;
  private int width,height;
  private int numPixels;

  private int blackPoint;
  private BlackPointEstimationMethod lastMethod;
  private int lastArgument;

  private static final int LUMINANCE_BITS = 5;
  private static final int LUMINANCE_SHIFT = 8 - LUMINANCE_BITS;
  private static final int LUMINANCE_BUCKETS = 1 << LUMINANCE_BITS;

  public PImageMonochromeBitmapSource(PImage image) {
    this.pixels = image.pixels;
    width=image.width;
    height=image.height;
    numPixels=image.pixels.length;
    blackPoint = 0x7F;
    lastMethod = null;
    lastArgument = 0;
  }

  public boolean isBlack(int x, int y) {
    return computeRGBLuminance(getPixel(x, y)) < blackPoint;
  }

  public boolean isRotateSupported() {
    return false;
  }

  public MonochromeBitmapSource rotateCounterClockwise() {
    return this;
  }

  public BitArray getBlackRow(int y, BitArray row, int startX, int getWidth) {
    if (row == null) {
      row = new BitArray(getWidth);
    } 
    else {
      row.clear();
    }
    int[] pixelRow = getPixels(startX, y, getWidth);
    for (int i = 0; i < getWidth; i++) {
      if (computeRGBLuminance(pixelRow[i]) < blackPoint) {
        row.set(i);
      }
    }
    return row;
  }

  BitArray getBlackColumn(int x, BitArray column, int startY, int getHeight) {
    if (column == null) {
      column = new BitArray(getHeight);
    } 
    else {
      column.clear();
    }
    int[] pixelCol = getPixels(x,startY, getHeight);
    for (int i = 0; i < getHeight; i++) {
      if (computeRGBLuminance(pixelCol[i]) < blackPoint) {
        column.set(i);
      }
    }
    return column;
  }

  public int getHeight() {
    return height;
  }

  public int getWidth() {
    return width;
  }

  public void estimateBlackPoint(BlackPointEstimationMethod method, int argument) {

    if (!method.equals(lastMethod) || argument != lastArgument) {
      int[] histogram = new int[LUMINANCE_BUCKETS];
      if (method.equals(BlackPointEstimationMethod.TWO_D_SAMPLING)) {
        int minDimension = width < height ? width : height;
        int startI = height == minDimension ? 0 : (height - width) >> 1;
        int startJ = width == minDimension ? 0 : (width - height) >> 1;
        for (int n = 0; n < minDimension; n++) {
          int pixel = getPixel(startJ + n, startI + n);
          histogram[computeRGBLuminance(pixel) >> LUMINANCE_SHIFT]++;
        }
      } 
      else if (method.equals(BlackPointEstimationMethod.ROW_SAMPLING)) {
        if (argument < 0 || argument >= height) {
          throw new IllegalArgumentException("Row is not within the image: " + argument);
        }
        int[] rgbArray =getPixels(0, argument, width);
        for (int x = 0; x < width; x++) {
          histogram[computeRGBLuminance(rgbArray[x]) >> LUMINANCE_SHIFT]++;
        }
      } 
      else {
        throw new IllegalArgumentException("Unknown method: " + method);
      }
      try {
        blackPoint = BlackPointEstimator.estimate(histogram) << LUMINANCE_SHIFT;
      } 
      catch(ReaderException e) {

      }
      lastMethod = method;
      lastArgument = argument;
    }
  }

  public BlackPointEstimationMethod getLastEstimationMethod() {
    return lastMethod;
  }

  /**
   * Extracts luminance from a pixel from this source. By default, the source is assumed to use RGB,
   * so this implementation computes luminance is a function of a red, green and blue components as
   * follows:
   *
   * <code>Y = 0.299R + 0.587G + 0.114B</code>
   *
   * where R, G, and B are values in [0,1].
   */
  private int computeRGBLuminance(int pixel) {
    // Coefficients add up to 1024 to make the divide into a fast shift
    return (306 * ((pixel >> 16) & 0xFF) +
      601 * ((pixel >> 8) & 0xFF) +
      117 * (pixel & 0xFF)) >> 10;
  }

  private final int getPixel(int x, int y) {
    int idx=y*width+x;
    if (idx>=0 && idx<numPixels) {
      return pixels[idx];
    } 
    else {
      return 0xffffff; 
    }
  }

  private final int[] getPixels(int x, int y, int w) {
    int[] row=new int[w];
    System.arraycopy(pixels,y*width+x,row,0,w);
    return row;
  }
}

