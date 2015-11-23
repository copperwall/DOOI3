build:
	dmd *.d

test:
	dmd -unittest *.d

run:
	dmd -run *.d

clean:
	rm -f *.o DOOI3
