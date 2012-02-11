//
//  ILProfilerCompat.c
//
//  Created by Claus Broch on 03/02/12.
//  Copyright (c) 2012 Infinite Loop. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted
//  provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice, this list of conditions 
//    and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice, this list of 
//    conditions and the following disclaimer in the documentation and/or other materials provided 
//    with the distribution.
//  - Neither the name of Infinite Loop nor the names of its contributors may be used to endorse or 
//    promote products derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR 
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY 
//  WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#include <stdio.h>

//
// This file provides a workaround for an error that sometimes occurs when enabling code coverage
// metrics on iOS using LLVM/Clang and libprofile_rt.dylib:
//
//   Detected an attempt to call a symbol in system libraries that is not present on the iPhone:
//   fopen$UNIX2003 called from function llvm_gcda_start_file in image ...
//
// To fix this problem simply include this file in your testing target build.
//

FILE *fopen$UNIX2003(const char *filename, const char *mode);
size_t fwrite$UNIX2003(const void *ptr, size_t size, size_t nitems, FILE *stream);

FILE *fopen$UNIX2003(const char *filename, const char *mode) {
    return fopen(filename, mode);
}

size_t fwrite$UNIX2003(const void *ptr, size_t size, size_t nitems, FILE *stream) {
    return fwrite(ptr, size, nitems, stream);
}