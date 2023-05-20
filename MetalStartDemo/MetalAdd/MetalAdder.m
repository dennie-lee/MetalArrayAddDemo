//
//  MetalAdder.m
//  MetalStartDemo
//
//  Created by liqinghua on 13.4.23.
//

#import "MetalAdder.h"
#import <Metal/Metal.h>

//数组长度，1向左移动24位，即2的24次方：16777216
const unsigned int arrayLength = 1 << 24;
//每个数组缓存冲区长度
const unsigned int bufferSize = arrayLength * sizeof(float);

@implementation MetalAdder{
    id<MTLDevice> _mDevice;
    //根据扩展名为.metal文件中kernel定义的函数创建计算管道（项目Add文件）
    id<MTLComputePipelineState> _mAddFunctionPSO;
    // 指令队列
    id<MTLCommandQueue> _mCommandQueue;
    //数组数据缓冲区
    id<MTLBuffer> _mBufferA;
    id<MTLBuffer> _mBufferB;
    id<MTLBuffer> _mBufferResult;
}

- (instancetype)initWithDevice:(id<MTLDevice>)device{
    self = [super init];
    if (self){
        _mDevice = device;
        // Load the shader files with a .metal file extension in the project
        id<MTLLibrary> newDefaultLibrary = [_mDevice newDefaultLibrary];
        if (newDefaultLibrary == nil){
            NSLog(@"Failed to find the default library");
            return nil;
        }
        
        id<MTLFunction> newFunction = [newDefaultLibrary newFunctionWithName:@"add_arrays"];
        if (newFunction == nil){
            NSLog(@"Failed to find the adder function");
            return nil;
        }
        
        NSError *error;
        // Create a compute pipeline state object.
        //根据扩展名为.metal文件中kernel定义的函数创建计算管道（项目Add文件）
        _mAddFunctionPSO = [_mDevice newComputePipelineStateWithFunction:newFunction error:&error];
        if (_mAddFunctionPSO == nil){
            //  If the Metal API validation is enabled, you can find out more information about what
            //  went wrong.  (Metal API validation is enabled by default when a debug build is run
            //  from Xcode)
            NSLog(@"Failed to create pipeline state object,error : %@)",error);
            return nil;
        }
        // 指令队列
        _mCommandQueue = [_mDevice newCommandQueue];
        if (_mCommandQueue == nil){
            NSLog(@"Failed to find command queue");
            return nil;
        }
    }
    return self;
}

//初始化数组数据
- (void)prepareData{
    _mBufferA = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferB = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferResult = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    [self generateRandomFloatData:_mBufferA];
    [self generateRandomFloatData:_mBufferB];
}

- (void)generateRandomFloatData:(id<MTLBuffer>)buffer{
    float *dataPtr = buffer.contents;
    for (int index = 0; index < arrayLength; index++){
        dataPtr[index] = (float)rand() / (float)RAND_MAX;
    }
}

- (void)sendComputeCommand{
    //create a command buffer to hold commands
    //创建指令缓存冲区
    id<MTLCommandBuffer> commandBuffer = [_mCommandQueue commandBuffer];
    assert(commandBuffer != nil);
    
    //开始进行指令添加参数
    id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    assert(computeEncoder != nil);
    
    NSTimeInterval startTimeInterval = [[[NSDate alloc] init] timeIntervalSince1970];
    [self encodeAdderCommand:computeEncoder];
    
    //添加参数完毕，
    [computeEncoder endEncoding];
    //提交执行指令
    [commandBuffer commit];
    //等待计算完毕
    [commandBuffer waitUntilCompleted];
    NSTimeInterval endTimeInterval = [[[NSDate alloc] init] timeIntervalSince1970];
    NSLog(@"长度为：%u 的两个数组相加（Metal方式）花费的时间：%f",arrayLength,(endTimeInterval - startTimeInterval));
    //验证计算结果
    [self verifyResults];
}

- (void)encodeAdderCommand:(id<MTLComputeCommandEncoder>)computeEncoder{
    //encode pipeline state object and its parameters
    [computeEncoder setComputePipelineState:_mAddFunctionPSO];
    //此处的atIndex为0，与MSL函数中参数对应顺序对应
    [computeEncoder setBuffer:_mBufferA offset:0 atIndex:0];
    //此处的atIndex为1，与MSL函数中参数对应顺序对应
    [computeEncoder setBuffer:_mBufferB offset:0 atIndex:1];
    //此处的atIndex为1，与MSL函数中参数对应顺序对应
    [computeEncoder setBuffer:_mBufferResult offset:0 atIndex:2];
    
    //线程数量，此处对应[[thread_position_in_grid]]
    MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
    NSUInteger threadGroupSize = _mAddFunctionPSO.maxTotalThreadsPerThreadgroup;
    if (threadGroupSize > arrayLength){
        threadGroupSize = arrayLength;
    }
    //线程组大小
    MTLSize threadGroupsize = MTLSizeMake(threadGroupSize, 1, 1);
    [computeEncoder dispatchThreads:gridSize threadsPerThreadgroup:threadGroupsize];
}

- (void) verifyResults{
    float* a = _mBufferA.contents;
    float* b = _mBufferB.contents;
    float* result = _mBufferResult.contents;

    for (unsigned long index = 0; index < arrayLength; index++){
        if (result[index] != (a[index] + b[index])){
            NSLog(@"Compute ERROR: index=%lu result=%g vs %g=a+b\n",
                   index, result[index], a[index] + b[index]);
            assert(result[index] == (a[index] + b[index]));
        }
    }
    NSLog(@"Compute results as expected\n 结果验证成功");
}
@end
