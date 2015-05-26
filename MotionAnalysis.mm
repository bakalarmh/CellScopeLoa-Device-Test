
//
//  MotionAnalysis.m
//  CellScopeLoa

#import "MotionAnalysis.h"
#import "UIImage+OpenCV.h"
#import "FrameBuffer.h"


@implementation MAMotionObjects

@end

@implementation MotionAnalysis {
    dispatch_queue_t backgroundQueue;
    NSMutableArray* frameBufferList;
    NSMutableDictionary* resultsDict;
    NSMutableArray* wormObjects;
    
    cv::Mat flowAngThresh;
    float numWorms;
    float numSeconds;
}

-(id)initWithWidth:(NSInteger)width Height:(NSInteger)height
            Frames:(NSInteger)frames
            VideoCount:(NSInteger)maxVideos
{
    self = [super init];
    
    // Number of independent seconds to observe
    numSeconds = 5.0;
    
    frameBufferList = [[NSMutableArray alloc] init];
    backgroundQueue = dispatch_queue_create("com.cellscopeloa.analysis.bgqueue", NULL);
    
    return self;
}

- (void)processFrameBuffer:(FrameBuffer*)frameBuffer withResourceURL:(NSString*)videoURL
{
    [frameBufferList addObject:frameBuffer];
    dispatch_async(backgroundQueue, ^(void) {
        
        // Pop the latest frame buffer off of the stack
        FrameBuffer* localFrameBuffer = [frameBufferList lastObject];
        [frameBufferList removeLastObject];
        
        // Process the frame buffer
        resultsDict = [[NSMutableDictionary alloc] init];
        [self processFramesForMovie:localFrameBuffer];
        
        // Release the frame buffer
        [localFrameBuffer releaseFrameBuffers];
        
        // Send results to any listeners
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:videoURL forKey:@"ResourceURL"];
        
        NSString* errorString = [resultsDict objectForKey:@"ErrorString"];
        if (errorString == nil) {
            NSLog(@"No errors");
            NSMutableDictionary* motionObjects = [resultsDict objectForKey:@"MotionObjects"];
            float averageCount = (motionObjects.count/numSeconds);  // x, y, start, end
            
            [userInfo setObject:motionObjects forKey:@"MotionObjects"];
            [userInfo setObject:[NSNumber numberWithFloat:averageCount] forKey:@"AverageCount"];
        }
        else {
            [userInfo setObject:errorString forKey:@"ErrorString"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"eventAnalysisComplete" object:self userInfo:userInfo];
    });
}

- (void)processFramesForMovie:(FrameBuffer*) frameBuffer {
    // Initialize the wormObjects array
    wormObjects = [[NSMutableArray alloc] init];
    
    numWorms = 0;
    // Start at the first frame
    int frameIdx = 0;
    numWorms=0;
    // Movie dimensions
    int rows = 360;
    int cols = 480;
    // Algorithm parameters
    int framesToAvg = 7;
    int framesToSkip = 1;
    // Matrix for storing normalized frames
    cv::Mat movieFrameMatNorm=cv::Mat::zeros(rows, cols, CV_16UC1);
    cv::Mat movieFrameMatNorm2=cv::Mat::zeros(rows, cols, CV_16UC1);
    cv::Mat movieFrameMatNorm3=cv::Mat::zeros(rows, cols, CV_16UC1);
    cv::Mat movieFrameMatNorm4=cv::Mat::zeros(rows, cols, CV_16UC1);
    cv::Mat movieFrameMatNorm5=cv::Mat::zeros(rows, cols, CV_16UC1);
    // Temporary matrices for image processing
    cv::Mat movieFrameMatOld;
    cv::Mat movieFrameMatCum(rows,cols, CV_16UC1, cv::Scalar::all(0));
    cv::Mat movieFrameMatFirst;
    cv::Mat movieFrameMatDiff= cv::Mat::zeros(rows, cols, CV_16UC1);
    cv::Mat movieFrameMatDiffTmp;
    cv::Mat movieFrameMat;
    cv::Mat movieFrameMatLast;
    cv::Mat movieFrameMatIllum;
    cv::Mat movieFrameMatBW;
    cv::Mat movieFrameMatBWInv;
    cv::Mat movieFrameMatBWCopy;
    cv::Mat movieFrameMatDiffOrig;
    cv::Mat movieFrameMatNormOld;
    cv::Mat movieFrameMatDiff1= cv::Mat::zeros(rows, cols, CV_16UC1);
    cv::Mat movieFrameMatDiff2= cv::Mat::zeros(rows, cols, CV_16UC1);
    cv::Mat movieFrameMatDiff3= cv::Mat::zeros(rows, cols, CV_16UC1);
    cv::Mat movieFrameMatDiff4= cv::Mat::zeros(rows, cols, CV_16UC1);
    cv::Mat movieFrameMatDiff5= cv::Mat::zeros(rows, cols, CV_16UC1);
    double flicker1=0;
    double flicker2=0;
    double flicker3=0;
    double flicker4=0;
    double flicker5=0;
    double flickerOverall=0;
    int i = 0;
    int avgFrames = framesToAvg/framesToSkip;
    frameIdx = 0;
    int sumSum=0;
    cv::Mat diffTest=cv::Mat::zeros(rows, cols, CV_16UC1);;
    cv::Mat movieFrameMatOldTest;
    cv::Mat diffTest1=cv::Mat::zeros(rows, cols, CV_16UC1);;
    cv::Mat diffTest2=cv::Mat::zeros(rows, cols, CV_16UC1);;
    cv::Mat diffTest3=cv::Mat::zeros(rows, cols, CV_16UC1);;
    cv::Mat diffTest4=cv::Mat::zeros(rows, cols, CV_16UC1);;
    cv::Mat diffTest5=cv::Mat::zeros(rows, cols, CV_16UC1);;
    //calc ave sum and flicker
    cv::Scalar sumLast;
    cv::Scalar sumLast2;
    cv::Scalar sumLast3;
    double flickerLow=.8;
    double flickerHigh=1.2;
    while(frameIdx < ((frameBuffer.numFrames.integerValue))) {
        int bufferIdx = frameIdx;
        movieFrameMat = [frameBuffer getFrameAtIndex:bufferIdx];
        cv::Scalar sum=cv::sum(movieFrameMat);
        sumSum=sumSum+sum[0];
        double backVal;
        double maxValTrash;
        cv::minMaxLoc(movieFrameMat, &backVal, &maxValTrash);
        if (frameIdx>2){
            if (frameIdx<=34) {
                if (sumLast3[0]/sum[0]>flickerHigh || sumLast3[0]/sum[0]<flickerLow) {
                    flicker1++;
                    flickerOverall++;
                }
            }
            else if  (frameIdx<=62) {
                if (sumLast3[0]/sum[0]>flickerHigh || sumLast3[0]/sum[0]<flickerLow) {
                    flicker2++;
                    flickerOverall++;
                }
            }
            else if (frameIdx<=90) {
                if (sumLast3[0]/sum[0]>flickerHigh || sumLast3[0]/sum[0]<flickerLow) {
                    flicker3++;
                    flickerOverall++;
                }
            }
            else if (frameIdx<=118) {
                if (sumLast3[0]/sum[0]>flickerHigh || sumLast3[0]/sum[0]<flickerLow) {
                    flicker4++;
                    flickerOverall++;
                }
            }
            else if (frameIdx<=146) {
                if (sumLast3[0]/sum[0]>flickerHigh || sumLast3[0]/sum[0]<flickerLow) {
                    flicker5++;
                    flickerOverall++;
                }
            }
        }
        if (frameIdx>1) sumLast3=sumLast2;
        if (frameIdx>0) sumLast2=sumLast;
        sumLast=sum;
        frameIdx++;
    }
    if (flickerOverall <10) {
        NSLog(@"Lighting error is not enabled!");
        //[resultsDict setObject:@"LightingError" forKey:@"ErrorString"];
        //return;
        
    }
    double aveSum=sumSum/frameIdx;
    //try to correct for flicker
    frameIdx = 0;
    while(frameIdx < ((frameBuffer.numFrames.integerValue))) {
        int bufferIdx = frameIdx;
        movieFrameMat = [frameBuffer getFrameAtIndex:bufferIdx];
        cv::Scalar sum=cv::sum(movieFrameMat);
        movieFrameMat=movieFrameMat*(aveSum/sum[0]);
        frameIdx++;
    }
    i = 0;
    frameIdx = 0;
    cv::Mat tempFlow;
    cv::Mat magAng[2];
    cv::Mat ang=cv::Mat::zeros(rows, cols, CV_32FC1);
    cv::Mat angOld=cv::Mat::zeros(rows, cols, CV_32FC1);
    cv::Mat angTmp=cv::Mat::zeros(rows, cols, CV_32FC1);
    cv::Mat mag;
    cv::Mat flowAng=cv::Mat::zeros(rows, cols, CV_32FC1);
    cv::Mat flowMagThresh;
    cv::Mat flow=cv::Mat::zeros(rows, cols, CV_32FC1);
    cv::Mat flow1=cv::Mat::zeros(rows, cols, CV_32FC1);
    cv::Mat flow2=cv::Mat::zeros(rows, cols, CV_32FC1);
    cv::Mat flow3=cv::Mat::zeros(rows, cols, CV_32FC1);
    cv::Mat flow4=cv::Mat::zeros(rows, cols, CV_32FC1);
    cv::Mat flow5=cv::Mat::zeros(rows, cols, CV_32FC1);
    int numFrameToAdv=20;
    //estimage optical flow (short timescale)
    while(frameIdx < ((frameBuffer.numFrames.integerValue))) {
        int bufferIdx = frameIdx;
        if (frameIdx>0) movieFrameMatOld=movieFrameMat.clone();
        movieFrameMat = [frameBuffer getFrameAtIndex:bufferIdx];
        if (frameIdx>0) {
            calcOpticalFlowFarneback(movieFrameMatOld, movieFrameMat, tempFlow, 0.5, 3, 15, 3, 5, 1.2, 0);
            cv::split(tempFlow, magAng);
            cv::cartToPolar(magAng[0], magAng[1], mag, ang);
            cv::absdiff(ang, angOld, angTmp);
            flowAng=flowAng+angTmp;
            if (frameIdx<=29) {
                flow1=flow1+mag;
            }
            else if  (frameIdx<=58) {
                flow2=flow2+mag;
            }
            else if (frameIdx<=87) {
                flow3=flow3+mag;
            }
            else if (frameIdx<=116) {
                flow4=flow4+mag;
            }
            else if (frameIdx<=145) {
                flow5=flow5+mag;
            }
        }
        angOld=ang.clone();
        frameIdx=frameIdx+numFrameToAdv;
        
    }
    //calc long term flow mag
    frameIdx = 0;
    numFrameToAdv=5;
    while(frameIdx < ((frameBuffer.numFrames.integerValue))) {
        int bufferIdx = frameIdx;
        if (frameIdx>0) movieFrameMatOld=movieFrameMat;
        movieFrameMat = [frameBuffer getFrameAtIndex:bufferIdx];
        if (frameIdx>0) {
            calcOpticalFlowFarneback(movieFrameMatOld, movieFrameMat, tempFlow, 0.5, 3, 20, 3, 7, 1.5, 0);
            cv::split(tempFlow, magAng);
            cv::cartToPolar(magAng[0], magAng[1], mag, ang,true);
            flow=flow+mag;
        }
        frameIdx=frameIdx+numFrameToAdv;
    }
    int z=5;
    i=0;
    for(int i=0; i<z; i++) {
        cv::medianBlur(flowAng,flowAng,5);
    }
    threshold(flowAng, flowAngThresh,10, 255, CV_THRESH_TOZERO);
    threshold(flowAngThresh, flowAngThresh, 1 , 255, CV_THRESH_BINARY);
    flowAngThresh=flowAngThresh/255;
    threshold(flow, flowMagThresh, 2, 255, CV_THRESH_BINARY);
    flowMagThresh=flowMagThresh/255;
    flowMagThresh =  cv::Scalar::all(1) - flowMagThresh;
    int erosionSize0=10;
    cv::Mat element0 = getStructuringElement(0, cv::Size( 2*erosionSize0 + 1, 2*erosionSize0+1 ),cv::Point( erosionSize0, erosionSize0));
    cv::dilate( flowAngThresh, flowAngThresh, element0 );
    cv::erode( flowAngThresh, flowAngThresh, element0 );
    cv::erode( flowAngThresh, flowAngThresh, element0 );
    cv::Scalar flowAngThreshS=cv::sum(flowAngThresh);
    if (flowAngThreshS[0] > 10000) {
        // Motion error is disabled
        // [resultsDict setObject:@"MotionError" forKey:@"ErrorString"];
        // return;
    }
    
    i = 0;
    frameIdx = 0;
    double focusMeasure;
    double focusMeasure2;
    // Compute difference image from current movie
    while(frameIdx < (frameBuffer.numFrames.integerValue)) {
        while(i < avgFrames) {
            int bufferIdx = frameIdx;
            movieFrameMat = [frameBuffer getFrameAtIndex:bufferIdx];
            double backVal;
            double maxValTrash;
            cv::minMaxLoc(movieFrameMat, &backVal, &maxValTrash);
            if (i==0){
                threshold(movieFrameMat, movieFrameMatBW,150, 255, CV_THRESH_BINARY);
                cv::Mat element = getStructuringElement(CV_SHAPE_ELLIPSE, cv::Size( 10,10 ), cv::Point( 2, 2 ));
                cv::morphologyEx(movieFrameMatBW,movieFrameMatBW, CV_MOP_DILATE, element );
                movieFrameMatBWInv =  cv::Scalar::all(255) - movieFrameMatBW.clone();
                movieFrameMatBW.convertTo(movieFrameMatBW, CV_16UC1);
                movieFrameMatBW=movieFrameMatBW*255;
                movieFrameMatBWInv.convertTo(movieFrameMatBWInv, CV_16UC1);
                movieFrameMatBWInv=movieFrameMatBWInv/255;
                movieFrameMatIllum=movieFrameMat.clone();
                movieFrameMatIllum.convertTo(movieFrameMatIllum, CV_16UC1);
                cv::Rect myROI(100, 100, 200, 200);
                cv::Mat croppedImage = movieFrameMat(myROI);
                cv::Mat lap;
                cv::Laplacian(croppedImage, lap, CV_64F);
                cv::Scalar mu, sigma;
                cv::meanStdDev(lap, mu, sigma);
                focusMeasure = sigma.val[0]*sigma.val[0];
                NSLog(@"focus measure is, %f", focusMeasure);
                int ksize=5;
                cv::Mat Gx, Gy;
                cv::Sobel(croppedImage, Gx, CV_64F, 1, 0, ksize);
                cv::Sobel(croppedImage, Gy, CV_64F, 0, 1, ksize);
                cv::Mat FM = Gx.mul(Gx) + Gy.mul(Gy);
                focusMeasure2 = cv::mean(FM).val[0];
                NSLog(@"focus measure2 is, %f", focusMeasure2);
            }
            movieFrameMat.convertTo(movieFrameMat, CV_16UC1);
            if (i == 0){
                movieFrameMatOld=movieFrameMat;
                movieFrameMat.release();
                movieFrameMat=cv::Mat();
            }
            else {
                movieFrameMatCum = movieFrameMatCum + movieFrameMat;
                movieFrameMatOld.release();
                movieFrameMatOld=cv::Mat();
                movieFrameMatOld=movieFrameMat;
                movieFrameMat.release();
                movieFrameMat=cv::Mat();
            }
            i=i+1;
            frameIdx = frameIdx + framesToSkip;
        }
        if (i == avgFrames){
            movieFrameMatNormOld=movieFrameMatCum.clone()/i;
        }
        if (i >= avgFrames) {
            // Grab the current movie from the frame buffer list
            int bufferIdx = frameIdx;
            movieFrameMat = [frameBuffer getFrameAtIndex:bufferIdx];
            // Convert the frame into 16 bit grayscale. Space for optimization
            movieFrameMat.convertTo(movieFrameMat, CV_16UC1);
            // Grab the first frame from the current ave from the frame buffer list
            int firstBufferIdx = (frameIdx-avgFrames+1);
            movieFrameMatFirst = [frameBuffer getFrameAtIndex:firstBufferIdx];
            movieFrameMatFirst.convertTo(movieFrameMatFirst, CV_16UC1);
            movieFrameMatCum = movieFrameMatCum - movieFrameMatFirst + movieFrameMat;
            movieFrameMat.release();
            movieFrameMat=cv::Mat();
            movieFrameMatFirst.release();
            movieFrameMatFirst=cv::Mat();
            cv::divide(movieFrameMatCum, avgFrames, movieFrameMatNorm);
            cv::absdiff(movieFrameMatNormOld, movieFrameMatNorm, movieFrameMatDiffTmp);
            movieFrameMatNormOld.release();
            movieFrameMatNormOld=cv::Mat();
            if (i<=34) {
                movieFrameMatDiff1 = movieFrameMatDiff1 + movieFrameMatDiffTmp;
            }
            else if  (i<=62) {
                movieFrameMatDiff2 = movieFrameMatDiff2 + movieFrameMatDiffTmp;
            }
            else if (i<=90) {
                movieFrameMatDiff3 = movieFrameMatDiff3 + movieFrameMatDiffTmp;
            }
            else if (i<=118) {
                movieFrameMatDiff4 = movieFrameMatDiff4 + movieFrameMatDiffTmp;
            }
            else if (i<=146) {
                movieFrameMatDiff5 = movieFrameMatDiff5 + movieFrameMatDiffTmp;
            }
            movieFrameMatDiffTmp.release();
            movieFrameMatDiffTmp=cv::Mat();
        }
        movieFrameMatNormOld=movieFrameMatNorm.clone();
        movieFrameMatNorm.release();
        movieFrameMatNorm=cv::Mat();
        frameIdx = frameIdx + framesToSkip;
        i = i+1;
    }
    flowAngThresh.convertTo(flowAngThresh, CV_16UC1);
    cv::Mat flowAngThreshInv=  cv::Scalar::all(1) - flowAngThresh;
    flowAngThreshInv=flowAngThreshInv*65535;
    cv::multiply(movieFrameMatDiff1, movieFrameMatBWInv, movieFrameMatDiff1);
    cv::multiply(movieFrameMatDiff2, movieFrameMatBWInv, movieFrameMatDiff2);
    cv::multiply(movieFrameMatDiff3, movieFrameMatBWInv, movieFrameMatDiff3);
    cv::multiply(movieFrameMatDiff4, movieFrameMatBWInv, movieFrameMatDiff4);
    cv::multiply(movieFrameMatDiff5, movieFrameMatBWInv, movieFrameMatDiff5);
    movieFrameMatDiff1=movieFrameMatDiff1*10;
    movieFrameMatDiff2=movieFrameMatDiff2*10;
    movieFrameMatDiff3=movieFrameMatDiff3*10;
    movieFrameMatDiff4=movieFrameMatDiff4*10;
    movieFrameMatDiff5=movieFrameMatDiff5*10;
    int gaussKernel00=5;
    GaussianBlur(movieFrameMatDiff1,movieFrameMatDiff1,cv::Size(gaussKernel00,gaussKernel00),0,0,4);
    GaussianBlur(movieFrameMatDiff2,movieFrameMatDiff2,cv::Size(gaussKernel00,gaussKernel00),0,0,4);
    GaussianBlur(movieFrameMatDiff3,movieFrameMatDiff3,cv::Size(gaussKernel00,gaussKernel00),0,0,4);
    GaussianBlur(movieFrameMatDiff4,movieFrameMatDiff4,cv::Size(gaussKernel00,gaussKernel00),0,0,4);
    GaussianBlur(movieFrameMatDiff5,movieFrameMatDiff5,cv::Size(gaussKernel00,gaussKernel00),0,0,4);
    cv::Scalar sum11=cv::sum(movieFrameMatDiff1);
    cv::Scalar sum22=cv::sum(movieFrameMatDiff2);
    cv::Scalar sum33=cv::sum(movieFrameMatDiff3);
    cv::Scalar sum44=cv::sum(movieFrameMatDiff4);
    cv::Scalar sum55=cv::sum(movieFrameMatDiff5);
    flowAngThresh.convertTo(flowAngThresh, CV_32FC1);
    flow1.convertTo(flow1, CV_32FC1);
    flow2.convertTo(flow2, CV_32FC1);
    flow3.convertTo(flow3, CV_32FC1);
    flow4.convertTo(flow4, CV_32FC1);
    flow5.convertTo(flow5, CV_32FC1);
    cv::Mat flowSumTemp=cv::Mat::zeros(rows, cols, CV_32FC1);
    cv::Mat flowSumTempThresh;
    cv::multiply(flow1, flowAngThresh, flowSumTemp);
    flowSumTemp.convertTo(flowSumTemp, CV_16UC1);
    cv::multiply(flowSumTemp, movieFrameMatBWInv, flowSumTemp);
    cv::Scalar flowSum1=cv::sum(flowSumTemp);
    cv::multiply(flow2, flowAngThresh, flowSumTemp);
    flowSumTemp.convertTo(flowSumTemp, CV_16UC1);
    cv::multiply(flowSumTemp, movieFrameMatBWInv, flowSumTemp);
    cv::Scalar flowSum2=cv::sum(flowSumTemp);
    cv::multiply(flow3, flowAngThresh, flowSumTemp);
    flowSumTemp.convertTo(flowSumTemp, CV_16UC1);
    cv::multiply(flowSumTemp, movieFrameMatBWInv, flowSumTemp);
    cv::Scalar flowSum3=cv::sum(flowSumTemp);
    cv::multiply(flow4, flowAngThresh, flowSumTemp);
    flowSumTemp.convertTo(flowSumTemp, CV_16UC1);
    cv::multiply(flowSumTemp, movieFrameMatBWInv, flowSumTemp);
    cv::Scalar flowSum4=cv::sum(flowSumTemp);
    cv::multiply(flow5, flowAngThresh, flowSumTemp);
    flowSumTemp.convertTo(flowSumTemp, CV_16UC1);
    cv::multiply(flowSumTemp, movieFrameMatBWInv, flowSumTemp);
    cv::Scalar flowSum5=cv::sum(flowSumTemp);
    cv::multiply(flow, flowAngThresh, flowSumTemp);
    flowSumTemp.convertTo(flowSumTemp, CV_16UC1);
    cv::multiply(flowSumTemp, movieFrameMatBWInv, flowSumTemp);
    cv::Rect myROI(60, 0, 360, 360);
    cv::Mat flowSumTempCrop = flowSumTemp(myROI);
    cv::Scalar flowSum=cv::sum(flowSumTempCrop);
    NSLog(@"done with loop, sums are %f, %f, %f, %f, %f", sum11[0],sum22[0],sum33[0],sum44[0],sum55[0]);
    NSLog(@"done with loop, flows are %f, %f, %f, %f, %f", flowSum1[0],flowSum2[0],flowSum3[0],flowSum4[0],flowSum5[0]);
    NSLog(@"done with loop, flow is, %f,", flowSum[0]);
    //estimate background
    int backSize=30;
    int backgroundSize=75; //was 75
    int backgroundSize2=75; //was 75
    int backgroundSize3=75; //was 75
    int backgroundSize4=75; //was 75
    int backgroundSize5=75; //was 75
    int flowCutoff=250000;
    
    if (flowSum[0]>flowCutoff && flicker1<50) {
        backgroundSize=50-((flowSum[0]-flowCutoff)/5000);
        if (backgroundSize<35) backgroundSize=35;
    }
    
    if (flowSum[0]>flowCutoff && flicker2<50){
        backgroundSize2=50-((flowSum[0]-flowCutoff)/5000);
        if (backgroundSize2<35) backgroundSize2=35;
    }
    
    if (flowSum[0]>flowCutoff && flicker3<50) {
        backgroundSize3=50-((flowSum[0]-flowCutoff)/5000);
        if (backgroundSize3<35) backgroundSize3=35;
    }
    
    if (flowSum[0]>flowCutoff && flicker4<50) {
        backgroundSize4=50-((flowSum[0]-flowCutoff)/5000);
        if (backgroundSize4<35) backgroundSize4=35;
    }
    
    if (flowSum[0]>flowCutoff && flicker5<50) {
        backgroundSize5=50-((flowSum[0]-flowCutoff)/5000);
        if (backgroundSize5<35) backgroundSize5=35;
    }
    cv::Mat backConvMat= cv::Mat::ones(backSize, backSize, CV_32FC1);
    backConvMat=backConvMat/(backSize*backSize);
    cv::Mat backgroundConvMat= cv::Mat::ones(backgroundSize,backgroundSize, CV_32FC1);
    backgroundConvMat=backgroundConvMat/(backgroundSize*backgroundSize);
    movieFrameMatDiff=movieFrameMatDiff+movieFrameMatBW+flowAngThreshInv;
    cv::filter2D(movieFrameMatDiff,movieFrameMatDiff,-1,backgroundConvMat, cv::Point(-1,-1));
    double backVal;
    double maxValTrash;
    cv::minMaxLoc(movieFrameMatDiff, &backVal, &maxValTrash);
    //new background calcs1
    cv::Mat movieFrameMatDiff1Back=movieFrameMatDiff1+movieFrameMatBW+flowAngThreshInv;;
    cv::dilate(movieFrameMatDiff1Back, movieFrameMatDiff1Back, backgroundConvMat, cv::Point(-1,-1),1,cv::BORDER_CONSTANT, cv::Scalar(cv::morphologyDefaultBorderValue()));
    double backVal1;
    double maxValTrash1;
    cv::minMaxLoc(movieFrameMatDiff1Back, &backVal1, &maxValTrash1);
    NSLog(@"movieframediff1back min, max is, %f, %f", backVal1, maxValTrash1 );
    if (backVal1<12) {
        backVal1=12;
    }
    //new background calcs2
    backgroundConvMat= cv::Mat::ones(backgroundSize2,backgroundSize2, CV_32FC1);
    backgroundConvMat=backgroundConvMat/(backgroundSize2*backgroundSize2);
    cv::Mat movieFrameMatDiff2Back=movieFrameMatDiff2+movieFrameMatBW+flowAngThreshInv;;
    cv::dilate(movieFrameMatDiff2Back, movieFrameMatDiff2Back, backgroundConvMat, cv::Point(-1,-1),1,cv::BORDER_CONSTANT, cv::Scalar(cv::morphologyDefaultBorderValue()));
    double backVal2;
    double maxValTrash2;
    cv::minMaxLoc(movieFrameMatDiff2Back, &backVal2, &maxValTrash2);
    if (backVal2<12) {
        backVal2=12;
    }
    //new background calcs3
    backgroundConvMat= cv::Mat::ones(backgroundSize3,backgroundSize3, CV_32FC1);
    backgroundConvMat=backgroundConvMat/(backgroundSize3*backgroundSize3);
    cv::Mat movieFrameMatDiff3Back=movieFrameMatDiff3+movieFrameMatBW+flowAngThreshInv;;
    cv::dilate(movieFrameMatDiff3Back, movieFrameMatDiff3Back, backgroundConvMat, cv::Point(-1,-1),1,cv::BORDER_CONSTANT, cv::Scalar(cv::morphologyDefaultBorderValue()));
    double backVal3;
    double maxValTrash3;
    cv::minMaxLoc(movieFrameMatDiff3Back, &backVal3, &maxValTrash3);
    if (backVal3<12) {
        backVal3=12;
    }
    //new background calcs4
    backgroundConvMat= cv::Mat::ones(backgroundSize4,backgroundSize4, CV_32FC1);
    backgroundConvMat=backgroundConvMat/(backgroundSize4*backgroundSize4);
    cv::Scalar sum4=cv::sum(movieFrameMatDiff4);
    cv::Mat movieFrameMatDiff4Back=movieFrameMatDiff4+movieFrameMatBW+flowAngThreshInv;;
    cv::dilate(movieFrameMatDiff4Back, movieFrameMatDiff4Back, backgroundConvMat, cv::Point(-1,-1),1,cv::BORDER_CONSTANT, cv::Scalar(cv::morphologyDefaultBorderValue()));
    double backVal4;
    double maxValTrash4;
    cv::minMaxLoc(movieFrameMatDiff4Back, &backVal4, &maxValTrash4);
    if (backVal4<12) {
        backVal4=12;
    }
    
    //new background calcs5
    backgroundConvMat= cv::Mat::ones(backgroundSize5,backgroundSize5, CV_32FC1);
    backgroundConvMat=backgroundConvMat/(backgroundSize5*backgroundSize5);
    cv::Mat movieFrameMatDiff5Back=movieFrameMatDiff5+movieFrameMatBW+flowAngThreshInv;;
    cv::dilate(movieFrameMatDiff5Back, movieFrameMatDiff5Back, backgroundConvMat, cv::Point(-1,-1),1,cv::BORDER_CONSTANT, cv::Scalar(cv::morphologyDefaultBorderValue()));
    double backVal5;
    double maxValTrash5;
    cv::minMaxLoc(movieFrameMatDiff5Back, &backVal5, &maxValTrash5);
    if (backVal5<12) {
        backVal5=12;
    }
    double backValCorr=2;
    if (focusMeasure2<50000) {
        float focusCorr=(focusMeasure2)-50000;
        focusCorr=focusCorr/38000;
        backValCorr=backValCorr+focusCorr;
    }
    if (focusMeasure<10) {
    }
    double backValCorr1=backValCorr;
    double backValCorr2=backValCorr;
    double backValCorr3=backValCorr;
    double backValCorr4=backValCorr;
    double backValCorr5=backValCorr;
    if (flicker1>5) {
        flicker1=5;
    }
    if (flicker2>5) {
        flicker2=5;
    }
    if (flicker3>5) {
        flicker3=5;
    }
    if (flicker4>5) {
        flicker4=5;
    }
    if (flicker5>5) {
        flicker5=5;
    }
    movieFrameMatDiff1=movieFrameMatDiff1-backVal1*backValCorr1;
    movieFrameMatDiff2=movieFrameMatDiff2-backVal2*backValCorr2;
    movieFrameMatDiff3=movieFrameMatDiff3-backVal3*backValCorr3;
    movieFrameMatDiff4=movieFrameMatDiff4-backVal4*backValCorr4;
    movieFrameMatDiff5=movieFrameMatDiff5-backVal5*backValCorr5;
    //median filter n times
    int n=3;
    for(int i=0; i<n; i++) {
        cv::medianBlur(movieFrameMatDiff1,movieFrameMatDiff1,3);
        cv::medianBlur(movieFrameMatDiff2,movieFrameMatDiff2,3);
        cv::medianBlur(movieFrameMatDiff3,movieFrameMatDiff3,3);
        cv::medianBlur(movieFrameMatDiff4,movieFrameMatDiff4,3);
        cv::medianBlur(movieFrameMatDiff5,movieFrameMatDiff5,3);
    }
    //erode
    int erosionSize=2;
    cv::Mat element = getStructuringElement(0, cv::Size( 2*erosionSize + 1, 2*erosionSize+1 ),cv::Point( erosionSize, erosionSize));
    cv::erode( movieFrameMatDiff1, movieFrameMatDiff1, element );
    cv::erode( movieFrameMatDiff2, movieFrameMatDiff2, element );
    cv::erode( movieFrameMatDiff3, movieFrameMatDiff3, element );
    cv::erode( movieFrameMatDiff4, movieFrameMatDiff4, element );
    cv::erode( movieFrameMatDiff5, movieFrameMatDiff5, element );
    int gaussKernel000=5;
    GaussianBlur(movieFrameMatDiff1,movieFrameMatDiff1,cv::Size(gaussKernel000,gaussKernel000),0,0,4);
    GaussianBlur(movieFrameMatDiff2,movieFrameMatDiff2,cv::Size(gaussKernel000,gaussKernel000),0,0,4);
    GaussianBlur(movieFrameMatDiff3,movieFrameMatDiff3,cv::Size(gaussKernel000,gaussKernel000),0,0,4);
    GaussianBlur(movieFrameMatDiff4,movieFrameMatDiff4,cv::Size(gaussKernel000,gaussKernel000),0,0,4);
    GaussianBlur(movieFrameMatDiff5,movieFrameMatDiff5,cv::Size(gaussKernel000,gaussKernel000),0,0,4);
    //convolve with mean subtracted gaussian
    cv::Mat gaussKer0=cv::getGaussianKernel(31, 100, CV_32F ); //was 51
    cv::Mat gaussKer= gaussKer0 * gaussKer0.t();
    cv::Scalar aveGaussKer=cv::mean(gaussKer);
    gaussKer=gaussKer-aveGaussKer[0];
    movieFrameMatDiff1.convertTo(movieFrameMatDiff1, CV_32F);
    cv::filter2D(movieFrameMatDiff1,movieFrameMatDiff1,-1,gaussKer, cv::Point(-1,-1));
    movieFrameMatDiff1=movieFrameMatDiff1*25500;
    movieFrameMatDiff1.convertTo(movieFrameMatDiff1, CV_16UC1);
    movieFrameMatDiff2.convertTo(movieFrameMatDiff2, CV_32F);
    cv::filter2D(movieFrameMatDiff2,movieFrameMatDiff2,-1,gaussKer, cv::Point(-1,-1));
    movieFrameMatDiff2=movieFrameMatDiff2*25500;
    movieFrameMatDiff2.convertTo(movieFrameMatDiff2, CV_16UC1);
    movieFrameMatDiff3.convertTo(movieFrameMatDiff3, CV_32F);
    cv::filter2D(movieFrameMatDiff3,movieFrameMatDiff3,-1,gaussKer, cv::Point(-1,-1));
    movieFrameMatDiff3=movieFrameMatDiff3*25500;
    movieFrameMatDiff3.convertTo(movieFrameMatDiff3, CV_16UC1);
    movieFrameMatDiff4.convertTo(movieFrameMatDiff4, CV_32F);
    cv::filter2D(movieFrameMatDiff4,movieFrameMatDiff4,-1,gaussKer, cv::Point(-1,-1));
    movieFrameMatDiff4=movieFrameMatDiff4*25500;
    movieFrameMatDiff4.convertTo(movieFrameMatDiff4, CV_16UC1);
    movieFrameMatDiff5.convertTo(movieFrameMatDiff5, CV_32F);
    cv::filter2D(movieFrameMatDiff5,movieFrameMatDiff5,-1,gaussKer, cv::Point(-1,-1));
    movieFrameMatDiff5=movieFrameMatDiff5*25500;
    movieFrameMatDiff5.convertTo(movieFrameMatDiff5, CV_16UC1);
    //median filter i times
    for(int i=0; i<0;i++) {
        cv::medianBlur(movieFrameMatDiff1,movieFrameMatDiff1,3);
        cv::medianBlur(movieFrameMatDiff2,movieFrameMatDiff2,3);
        cv::medianBlur(movieFrameMatDiff3,movieFrameMatDiff3,3);
        cv::medianBlur(movieFrameMatDiff4,movieFrameMatDiff4,3);
        cv::medianBlur(movieFrameMatDiff5,movieFrameMatDiff5,3);
    }
    movieFrameMatDiff1.convertTo(movieFrameMatDiff1, CV_8UC1);
    movieFrameMatDiff2.convertTo(movieFrameMatDiff2, CV_8UC1);
    movieFrameMatDiff3.convertTo(movieFrameMatDiff3, CV_8UC1);
    movieFrameMatDiff4.convertTo(movieFrameMatDiff4, CV_8UC1);
    movieFrameMatDiff5.convertTo(movieFrameMatDiff5, CV_8UC1);
    int thresh=1;
    int matchingSize=17;
    [self getLocalMaxima:movieFrameMatDiff1: matchingSize: thresh: 0:1:32];
    movieFrameMatDiff1.convertTo(movieFrameMatDiff1, CV_8UC1);
    cv::Mat movieFrameMatForWatGray;
    threshold(movieFrameMatDiff1, movieFrameMatForWatGray, 1, 255, CV_THRESH_TOZERO);
    threshold(movieFrameMatDiff1, movieFrameMatDiff1, 1, 255, CV_THRESH_BINARY);
    cv::Mat movieFrameMatDiff1ForWat=movieFrameMatDiff1.clone();
    [self getLocalMaxima:movieFrameMatDiff2: matchingSize: thresh: 0:33:60];
    movieFrameMatDiff2.convertTo(movieFrameMatDiff2, CV_8UC1);
    threshold(movieFrameMatDiff2, movieFrameMatForWatGray, 1, 255, CV_THRESH_TOZERO);
    threshold(movieFrameMatDiff2, movieFrameMatDiff2, 1, 255, CV_THRESH_BINARY);
    movieFrameMatDiff1ForWat=movieFrameMatDiff2.clone();
    [self getLocalMaxima:movieFrameMatDiff3: matchingSize: thresh: 0:61:90];
    movieFrameMatDiff3.convertTo(movieFrameMatDiff3, CV_8UC1);
    threshold(movieFrameMatDiff3, movieFrameMatDiff3, 1, 255, CV_THRESH_BINARY);
    threshold(movieFrameMatDiff3, movieFrameMatDiff3, 1, 255, CV_THRESH_BINARY);
    movieFrameMatDiff1ForWat=movieFrameMatDiff3.clone();
    [self getLocalMaxima:movieFrameMatDiff4: matchingSize: thresh: 0:91:120];
    movieFrameMatDiff4.convertTo(movieFrameMatDiff4, CV_8UC1);
    threshold(movieFrameMatDiff4, movieFrameMatDiff4, 1, 255, CV_THRESH_BINARY);
    threshold(movieFrameMatDiff4, movieFrameMatDiff4, 1, 255, CV_THRESH_BINARY);
    movieFrameMatDiff1ForWat=movieFrameMatDiff4.clone();
    [self getLocalMaxima:movieFrameMatDiff5: matchingSize: thresh: 0:121:150];
    movieFrameMatDiff5.convertTo(movieFrameMatDiff5, CV_8UC1);
    threshold(movieFrameMatDiff5, movieFrameMatDiff5, 1, 255, CV_THRESH_BINARY);
    threshold(movieFrameMatDiff5, movieFrameMatDiff5, 1, 255, CV_THRESH_BINARY);
    movieFrameMatDiff1ForWat=movieFrameMatDiff5.clone();
    numWorms=numWorms/5;
    cv::Scalar flowAngThreshSum=cv::sum(flowAngThresh);
    cv::Scalar highSigSum=cv::sum(movieFrameMatBWInv);
    float totalArea=480*360;
    float ignoredArea=480*360-flowAngThreshSum[0]+480*360-highSigSum[0];
    numWorms=numWorms*(totalArea/(totalArea-ignoredArea));
    NSLog(@"numWorms %f", numWorms);
    movieFrameMatDiff.release();
    movieFrameMatDiff1.release();
    movieFrameMatDiff2.release();
    movieFrameMatDiff3.release();
    movieFrameMatDiff4.release();
    movieFrameMatDiff5.release();
    movieFrameMatBW.release();
    
    [resultsDict setObject:wormObjects forKey:@"MotionObjects"];
}

-(cv::vector <cv::Point>) getLocalMaxima:(const cv::Mat) src:(int) matchingSize: (int) threshold: (int) gaussKernel:(int) starti :(int) endi
{
    cv::vector <cv::Point> vMaxLoc(0);
    vMaxLoc.reserve(100); // Reserve place for fast access
    cv::Mat processImg = src.clone();
    int w = src.cols;
    int h = src.rows;
    int searchWidth  = w - matchingSize;
    int searchHeight = h - matchingSize;
    int matchingSquareCenter = matchingSize/2;
    if(gaussKernel > 1) // If You need a smoothing
    {
        GaussianBlur(processImg,processImg,cv::Size(gaussKernel,gaussKernel),0,0,4);
    }
    uchar* pProcess = (uchar *) processImg.data; // The pointer to image Data
    int shift = matchingSquareCenter * ( w + 1);
    int k = 0;
    for(int y=0; y < searchHeight; ++y)
    {
        int m = k + shift;
        for(int x=0;x < searchWidth ; ++x)
        {
            if (pProcess[m++] >= threshold)
            {
                cv::Point locMax;
                cv::Mat mROI(processImg, cv::Rect(x,y,matchingSize,matchingSize));
                minMaxLoc(mROI,NULL,NULL,NULL,&locMax);
                if (locMax.x == matchingSquareCenter && locMax.y == matchingSquareCenter)
                {
                    vMaxLoc.push_back(cv::Point( x+locMax.x,y + locMax.y ));
                    int xi=x+locMax.x;
                    int yi= y+locMax.y;
                    Float32 val=flowAngThresh.at<Float32>(yi, xi);
                    if (val==1){
                        // Add worm to the results dictionary
                        MAMotionObjects* worm = [[MAMotionObjects alloc] init];
                        worm.x = xi;
                        worm.y = yi;
                        worm.start = starti;
                        worm.end = endi;
                        [wormObjects addObject:worm];
                        numWorms=numWorms+1;
                    }
                    else {
                        NSLog(@"point rejected due to motion");
                    }
                }
            }
        }
        k += w;
    }
    return vMaxLoc;
}

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error) {
        NSLog(@"error saving image");
        
    } else {
        NSLog(@"image saved in photo album");
    }
}


@end
