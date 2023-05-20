//
//  NormalAdd.m
//  MetalStartDemo
//
//  Created by liqinghua on 13.4.23.
//

#import <Foundation/Foundation.h>

//正常数组相加函数
void add_arrays(const float* inA,
                const float* inB,
                float* result,
                int length){
    for(int index = 0; index < length; index++){
        result[index] = inA[index] + inB[index];
    }
}
