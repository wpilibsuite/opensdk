.PHONY: main
main: main-c main-cpp

main-c: main.c
	${CC} ${CFLAGS} -Werror -o $@ $<
main-cpp: main.c
	${CXX} ${CXXFLAGS} -Wno-deprecated -Werror -o $@ $<
clean:
	rm -f main-c main-cpp
	rm -f main-c.exe main-cpp.exe
