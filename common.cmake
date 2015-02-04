﻿option(CMGDK_DEBUG "Use Debug CMGDK" ON)

if(CMGDK_DEBUG)
	set(CMGDK_BUILD_TYPE "Debug")
else()
	set(CMGDK_BUILD_TYPE "Release")
endif()

IF(WIN32)
	OPTION(USE_64_BIT	"Build 64bit Library" FALSE)

	IF(MSVC AND USE_64_BIT)
		OPTION(BUILD_INTEL64		"Optimize for Intel 64"						FALSE	)
		OPTION(BUILD_AMD64			"Optimize for AMD 64"						FALSE	)
	ENDIF()
ELSE(WIN32)
	OPTION(USE_CPP14				"Use C++ 14"							FALSE	)
	OPTION(USE_CPP11				"Use C++ 11"							TRUE	)
	OPTION(USE_ICE_CREAM			"Use IceCream"							TRUE	)

	IF(APPLE)
		OPTION(USE_LLVM_CLANG			"Use LLVM Clang"						TRUE	)
	ELSE()
		OPTION(USE_LLVM_CLANG			"Use LLVM Clang"						FALSE	)
	ENDIF()

	OPTION(USE_ELECTRIC_FENCE		"Use ElectricFence"						FALSE	)
	OPTION(USE_GPERF_TOOLS			"Use Google Performance Tools"			FALSE	)

	OPTION(USE_ALL_STATIC			"Use All Static"						FALSE	)
	OPTION(USE_STATIC_GLIBC			"Use Static libgcc"						FALSE	)
	OPTION(USE_STATIC_STDCXX		"Use Static libstdc++"					FALSE	)

	OPTION(DISABLE_RTTI				"Disable RTTI"							FALSE	)

	OPTION(USE_SSE2					"Use SSE2 (only X86/64)"				TRUE	)
ENDIF(WIN32)

IF(USE_LLVM_CLANG)
OPTION(USE_LLVM_CLANG_STATIC_ANALYZER	"the static analyzer"				OFF		)
ENDIF(USE_LLVM_CLANG)

IF(WIN32)
	IF(USE_64_BIT)
		SET(HGL_BITS 64)
		SET(WIN_3RD_ARCH "x64")
	ELSE(USE_64_BIT)
		SET(HGL_BITS 32)
		SET(WIN_3RD_ARCH "Win32")
	ENDIF(USE_64_BIT)
ELSE(WIN32)
	if(CMAKE_SIZEOF_VOID_P EQUAL 8)
		MESSAGE("Target OS bits is 64")
		SET(HGL_BITS	64)
	endif(CMAKE_SIZEOF_VOID_P EQUAL 8)

	if(CMAKE_SIZEOF_VOID_P EQUAL 4)
		MESSAGE("Target OS bits is 32")
		SET(HGL_BITS	32)
	endif(CMAKE_SIZEOF_VOID_P EQUAL 4)
ENDIF(WIN32)

IF(HGL_BITS EQUAL 32)
	add_definitions(-DHGL_32_BITS)
	add_definitions(-DHGL_POINTER_UINT=uint32)
ELSE()
	add_definitions(-DHGL_64_BITS)
	add_definitions(-DHGL_POINTER_UINT=uint64)
ENDIF(HGL_BITS EQUAL 32)

ADD_DEFINITIONS("-DUNICODE -D_UNICODE")

IF(USE_LLVM_CLANG_STATIC_ANALYZER)
	add_definitions("--analyze")
ENDIF(USE_LLVM_CLANG_STATIC_ANALYZER)

SET(HGL_PLATFORM_STRING	${CMAKE_SYSTEM_NAME}_${CMAKE_SYSTEM_PROCESSOR}_${CMGDK_BUILD_TYPE})
IF(UNIX)
	ADD_DEFINITIONS(-DHGL_PLATFORM_STRING="${HGL_PLATFORM_STRING}")
ELSE()
	ADD_DEFINITIONS(-DHGL_PLATFORM_STRING=L"${HGL_PLATFORM_STRING}")

	ADD_DEFINITIONS(-D_WINSOCKAPI_)
ENDIF()

message("HGL_PLATFORM_STRING:" ${HGL_PLATFORM_STRING})

SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMGDK_PATH}/bin/${HGL_PLATFORM_STRING})
SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMGDK_PATH}/lib/${HGL_PLATFORM_STRING})
SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMGDK_PATH}/plug-in/${HGL_PLATFORM_STRING})

link_directories(${CMAKE_LIBRARY_OUTPUT_DIRECTORY})

IF(UNIX)
SET(LIB_3RD_FIND_HINT	/usr/lib${HGL_BITS}
						/usr/local/lib${HGL_BITS}
						/usr/lib
						/usr/local/lib
						/usr/lib/${CMAKE_SYSTEM_PROCESSOR}-linux-gnu)

MESSAGE("UNIX LIB 3RD FIND HINT:" ${LIB_3RD_FIND_HINT})
ENDIF(UNIX)

IF(WIN32)
SET(INC_3RD_FIND_HINT ${CMGDK_PATH}/3rdpty/inc)
SET(LIB_3RD_FIND_HINT ${CMGDK_PATH}/3rdpty/lib${HGL_BITS})
ENDIF(WIN32)

link_directories(${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})

IF(UNIX)
	IF(USE_ICE_CREAM)
		IF(USE_LLVM_CLANG)
			SET(CMAKE_C_COMPILER /usr/lib/icecc/bin/clang)
			SET(CMAKE_CXX_COMPILER /usr/lib/icecc/bin/clang++)
		ELSE(USE_LLVM_CLANG)
			SET(CMAKE_C_COMPILER /usr/lib/icecc/bin/gcc)
			SET(CMAKE_CXX_COMPILER /usr/lib/icecc/bin/g++)
		ENDIF(USE_LLVM_CLANG)
	ELSE(USE_ICE_CREAM)
		IF(USE_LLVM_CLANG)
			SET(CMAKE_C_COMPILER clang)
			SET(CMAKE_CXX_COMPILER clang++)
		ENDIF(USE_LLVM_CLANG)
	ENDIF(USE_ICE_CREAM)

	if(USE_ALL_STATIC)
		add_definitions("-static")
	endif(USE_ALL_STATIC)

	if(USE_STATIC_GLIBC)
		add_definitions("-static-libgcc")
	endif(USE_STATIC_GLIBC)

	if(USE_STATIC_STDCXX)
		add_definitions("-static-libstdc++")
	endif(USE_STATIC_STDCXX)

	IF(USE_CPP14)
		SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
		add_definitions("-DHGL_CPP14")
		add_definitions("-DHGL_CPP11")
	ELSE(USE_CPP14)
		IF(USE_CPP11)
			SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
			add_definitions("-DHGL_CPP11")
		ENDIF(USE_CPP11)
	ENDIF(USE_CPP14)

	SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c11")

	IF(CMGDK_DEBUG)
		add_definitions(-ggdb3)
	ELSE()
		add_definitions(-Ofast)
	ENDIF()

	if(DISABLE_RTTI)
		add_definitions(-fno-rtti)
	endif()

	if(USE_SSE2)
		add_definitions(-msse2)
	endif()
ENDIF(UNIX)
