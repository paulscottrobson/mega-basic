#OBJS specifies which files to compile as part of the project
OBJS = framework\main.cpp framework\gfx.cpp framework\debugger.cpp sys_processor.cpp sys_debug_65816.cpp 
#CC specifies which compiler we're using
CC = g++

#INCLUDE_PATHS specifies the additional include paths we'll need
INCLUDE_PATHS = -IC:\sdl2\include\SDL2 -Iframework -I.

#LIBRARY_PATHS specifies the additional library paths we'll need
LIBRARY_PATHS = -LC:\sdl2\lib

#COMPILER_FLAGS specifies the additional compilation options we're using
# -w suppresses all warnings
# -Wl,-subsystem,windows gets rid of the console window
COMPILER_FLAGS = -DINCLUDE_DEBUGGING_SUPPORT -DWINDOWS

#LINKER_FLAGS specifies the libraries we're linking against
LINKER_FLAGS = -lmingw32 -lSDL2main -lSDL2

#OBJ_NAME specifies the name of our exectuable
OBJ_NAME = m65816.exe

#This is the target that compiles our executable
all : $(OBJS)
	$(CC) $(OBJS) $(INCLUDE_PATHS) $(LIBRARY_PATHS) $(COMPILER_FLAGS) $(LINKER_FLAGS) -o $(OBJ_NAME)
