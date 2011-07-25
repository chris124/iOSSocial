//
//  iOSSMultipartPOSTRequest.m
//  iOSSocial
//
//  Created by Christopher White on 7/20/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "iOSSMultipartPOSTRequest.h"
#import "iOSSUploadFileInfo.h"

@interface iOSSMultipartPOSTRequest ()

- (NSString *)preparedBoundary;

- (void)startRequestBody;
- (NSInteger)appendBodyString:(NSString *)string;
- (void)finishRequestBody;

- (void)finishMediaInputStream;
- (void)handleStreamCompletion;
- (void)handleStreamError:(NSError *)error;

@property (nonatomic, copy) NSString *pathToBodyFile;
@property (nonatomic, retain) NSOutputStream *bodyFileOutputStream;

@property (nonatomic, retain) iOSSUploadFileInfo *fileToUpload;
@property (nonatomic, retain) NSInputStream *uploadFileInputStream;

@property (nonatomic, copy) iOSSBodyCompletionBlock prepCompletionBlock;
@property (nonatomic, copy) iOSSBodyErrorBlock prepErrorBlock;

@property (nonatomic, assign, getter=isStarted) BOOL started;
@property (nonatomic, assign, getter=isFirstBoundaryWritten) BOOL firstBoundaryWritten;

@end

@implementation iOSSMultipartPOSTRequest

@synthesize HTTPBoundary;
@synthesize formParameters;
@synthesize pathToBodyFile;
@synthesize bodyFileOutputStream;
@synthesize fileToUpload;
@synthesize uploadFileInputStream;
@synthesize prepCompletionBlock;
@synthesize prepErrorBlock;
@synthesize started;
@synthesize firstBoundaryWritten;

- (void)setUploadFile:(NSString *)path 
          contentType:(NSString *)type
            nameParam:(NSString *)nameParam 
             filename:(NSString *)fileName
{
    iOSSUploadFileInfo *info = [[iOSSUploadFileInfo alloc] init];
    info.localPath = path;
    info.fileName = fileName;
    info.nameParam = nameParam;
    info.contentType = type;
    
    self.fileToUpload = info;
}

- (void)startRequestBody 
{
    if (!self.started) {
        self.started = YES;
        
        [self setHTTPMethod:@"POST"];
        NSString *format = @"multipart/form-data; boundary=%@";
        NSString *contentType = [NSString stringWithFormat:format,
                                 self.HTTPBoundary];
        [self setValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidStr = CFUUIDCreateString(kCFAllocatorDefault, uuid);
        NSString *extension = @"multipartbody";
        NSString *bodyFileName = [(__bridge NSString *)uuidStr
                                  stringByAppendingPathExtension:extension];
        CFRelease(uuidStr);
        CFRelease(uuid);        
        
        self.pathToBodyFile = [NSTemporaryDirectory()
                               stringByAppendingPathComponent:bodyFileName];
        NSString *bodyPath = self.pathToBodyFile;
        self.bodyFileOutputStream = [NSOutputStream
                                     outputStreamToFileAtPath:bodyPath
                                     append:YES];
        
        [self.bodyFileOutputStream open];
    }
}

- (NSInteger)appendBodyString:(NSString *)string 
{
    [self startRequestBody];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self.bodyFileOutputStream write:[data bytes] maxLength:[data length]];
}

- (NSString *)preparedBoundary 
{
    NSString *boundaryFormat =  self.firstBoundaryWritten ? @"\r\n--%@\r\n" : @"--%@\r\n";
    self.firstBoundaryWritten = YES;
    return [NSString stringWithFormat:boundaryFormat, self.HTTPBoundary];
}

- (void)finishRequestBody
{
    
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode 
{
    uint8_t buf[1024*100];
    NSUInteger len = 0;
    switch(eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"Media file opened");
            break;
        case NSStreamEventHasBytesAvailable:
            len = [self.uploadFileInputStream read:buf maxLength:1024];
            if (len) {
                [self.bodyFileOutputStream write:buf maxLength:len];
            } else {
                NSLog(@"Buffer finished; wrote to %@", self.pathToBodyFile);
                [self handleStreamCompletion];
            }
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"ERROR piping image to body file %@", [stream streamError]);
            self.prepErrorBlock(self, [stream streamError]);
            break;
        default:
            NSLog(@"Unhandled stream event (%d)", eventCode);
            break;
    }
}

- (void)handleStreamCompletion 
{
    [self finishMediaInputStream];
    [self finishRequestBody];
    self.prepCompletionBlock(self);
}

- (void)finishMediaInputStream 
{
    [self.uploadFileInputStream close];
    [self.uploadFileInputStream removeFromRunLoop:[NSRunLoop currentRunLoop] 
                                          forMode:NSDefaultRunLoopMode];
    self.uploadFileInputStream = nil;
}

- (void)handleStreamError:(NSError *)error 
{
    [self finishMediaInputStream];
    self.prepErrorBlock(self, error);
}

- (void)prepareForUploadWithCompletionBlock:(iOSSBodyCompletionBlock)completion 
                                 errorBlock:(iOSSBodyErrorBlock)error
{
    self.prepCompletionBlock = completion;
    self.prepErrorBlock = error;
    
    [self startRequestBody];

    NSMutableString *params = [NSMutableString string];
     /*
    NSArray *keys = [self.formParameters allKeys];
    for (NSString *key in keys) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
        [params appendString:[self preparedBoundary]]; 
        NSString *fmt = @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n"; 
        [params appendFormat:fmt, key]; 
        [params appendFormat:@"%@", [self.formParameters objectForKey:key]]; 
        [pool release];
    } 
    */
    if ([params length]) {
        if ([self appendBodyString:params] == -1) { 
            self.prepErrorBlock(self, [self.bodyFileOutputStream streamError]); return;
        }
    }
    
    if (self.fileToUpload) {
        NSMutableString *str = [[NSMutableString alloc] init];
        [str appendString:[self preparedBoundary]];
        [str appendString:@"Content-Disposition: form-data; "];
        [str appendFormat:@"name=\"%@\"; ", self.fileToUpload.nameParam];
        [str appendFormat:@"filename=\"%@\"\r\n", self.fileToUpload.fileName];
        NSString *contentType = self.fileToUpload.contentType;
        [str appendFormat:@"Content-Type: %@\r\n\r\n", contentType];
        [self appendBodyString:str];
        
        NSLog(@"Preparing to stream %@", self.fileToUpload.localPath);
        NSString *path = self.fileToUpload.localPath;
        NSInputStream *mediaInputStream = [[NSInputStream alloc] 
                                           initWithFileAtPath:path];
        self.uploadFileInputStream = mediaInputStream;
        
        [self.uploadFileInputStream setDelegate:self];
        [self.uploadFileInputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                              forMode:NSDefaultRunLoopMode];
        [self.uploadFileInputStream open];
    } else {
        [self handleStreamCompletion];
    }
}

- (NSString *)HTTPBoundary 
{
    NSAssert2(([HTTPBoundary length] > 0), @"-[%@ %@] Invalid or nil HTTPBoundary", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return HTTPBoundary;
}

- (void)setHTTPBoundary:(NSString *)boundary 
{
    if (HTTPBoundary == nil) {
        HTTPBoundary = [boundary copy];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"HTTPBoundary cannot be changed once set (old='%@' new='%@')", HTTPBoundary, boundary]
                                     userInfo:nil];
    }
}


@end
