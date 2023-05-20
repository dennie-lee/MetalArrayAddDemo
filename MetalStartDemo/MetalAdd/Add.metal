//
//  Add.metal
//  MetalStartDemo
//
//  Created by liqinghua on 13.4.23.
//

#include <metal_stdlib>
using namespace metal;

/*
 //正常数组相加函数
 void add_arrays(const float* inA,
                 const float* inB,
                 float* result,
                 int length){
     for(int index = 0; index < length; index++){
         result[index] = inA[index] + inB[index];
     }
 }
 */

/*
正常相加函数和Metal相加函数的区别
NormalAdd and MetalAdd are similar, but there are some important differences in the MSL version. Take a closer look at Listing 2.
 First, the function adds the kernel keyword, which declares that the function is:
 A public GPU function. Public functions are the only functions that your app can see. Public functions also can’t be called by other shader functions.
 A compute function (also known as a compute kernel), which performs a parallel calculation using a grid of threads.
 
 See Using a Render Pipeline to Render Primitives to learn the other function keywords used to declare public graphics functions.

 The add_arrays function declares three of its arguments with the device keyword, which says that these pointers are in the device address space. MSL defines several disjoint address spaces for memory. Whenever you declare a pointer in MSL, you must supply a keyword to declare its address space. Use the device address space to declare persistent memory that the GPU can read from and write to.

 Listing 2 removes the for-loop from Listing 1, because the function is now going to be called by multiple threads in the compute grid. This sample creates a 1D grid of threads that exactly matches the array’s dimensions, so that each entry in the array is calculated by a different thread.

 To replace the index previously provided by the for-loop, the function takes a new index argument, with another MSL keyword, thread_position_in_grid, specified using C++ attribute syntax. This keyword declares that Metal should calculate a unique index for each thread and pass that index in this argument. Because add_arrays uses a 1D grid, the index is defined as a scalar integer. Even though the loop was removed, Listing 1 and Listing 2 use the same line of code to add the two numbers together. If you want to convert similar code from C or C++ to MSL, replace the loop logic with a grid in the same way.
 */

/// This is a Metal Shading Language (MSL) function equivalent to the add_arrays() C function, used to perform the calculation on a GPU.
kernel void add_arrays(device const float* inA,
                       device const float* inB,
                       device float* result,
                       uint index[[thread_position_in_grid]]){
    // the for-loop is replaced with a collection of threads, each of which
    // calls this function.
    result[index] = inA[index] + inB[index];
}

