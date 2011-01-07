ipk::
	- rm wsz-arm.ipk
	tar -cvf control.tar ./control
	gzip control.tar
	tar -cvf data.tar ./home
	gzip data.tar
	tar -cvf wsz_1.0_arm ./control.tar.gz ./data.tar.gz
	gzip wsz_1.0_arm
	mv wsz_1.0_arm.gz wsz_1.0_arm.ipk
	rm *.gz