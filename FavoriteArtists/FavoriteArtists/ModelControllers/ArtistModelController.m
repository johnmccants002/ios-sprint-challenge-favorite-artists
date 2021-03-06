//
//  ArtistModelController.m
//  FavoriteArtists
//
//  Created by John McCants on 2/18/21.
//

#import "ArtistModelController.h"
#import "Artist.h"

static NSString *const baseURLString = @"https://www.theaudiodb.com/api/v1/json/1/search.php?";

@implementation ArtistModelController

-(instancetype)init
{
    if (self = [super init]) {
        _artists = [[NSMutableArray alloc] init];
        
    }
    return self;
}

+ (void)fetchArtist:(nonnull NSString *)searchTerm completionHandler:(nonnull ArtistCompletion)completionHandler
{
    if (!completionHandler) return;
    
    NSLog(@"1. Fetch Artists function starting");
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc]initWithString:baseURLString];
    
    urlComponents.queryItems = @[[NSURLQueryItem queryItemWithName:@"s" value:searchTerm]];
    
    NSURL *url = urlComponents.URL;
    
    NSLog(@"2. URL: %@", url);
    
    [[NSURLSession.sharedSession dataTaskWithURL:url
                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
    NSLog(@"3. Starting URL Session DataTaskWithURL");
    NSLog(@"Data: %@", data);
    NSLog(@"Response: %@", response.description);
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSUInteger dataLength = [data length];
    
        if (error) {
            NSLog(@"Error fetching artist: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
            return;
        }
        
        NSError *jsonError;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
        if (!dictionary) {
            NSLog(@"Error decoding JSON: %@", jsonError);
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, jsonError);
            });
            return;
        }
        
        NSError *dictError;
        
        @try
        {
            Artist *result = [[Artist alloc] initWithSearchResults:dictionary];
            
            NSLog(@"Dictionary Artist: %@", dictionary);
            if (!result) {
                NSLog(@"No Decoding Dictionary");
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(nil, dictError);
                });
                return;
            }
            
            NSLog(@"Result Data: %@", result);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(result, nil);
            });
        } @catch(id anException) {
            NSLog(@"Error fetching artist: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
            return;
        }
    
      @finally {
        
      }
    }] resume];
}

-(NSString *)filePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = paths[0];
    path = [path stringByAppendingPathComponent:@"artists"];
    path = [path stringByAppendingPathExtension:@"json"];
    return path;
}

- (void)saveToPersistentStore
{
    NSString *artistKey = @"artist";
    NSString *artistPath = [self filePath];
    NSMutableArray *artists = [[NSMutableArray alloc]init];
    
    for (Artist *artist in self.artists)
    {
        NSDictionary *artistDict = artist.toDictionary;
        [artists addObject:artistDict];
    }
    
    NSDictionary *dict = @{artistKey : artists};
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSURL *urlPath = [NSURL fileURLWithPath:artistPath];
    [data writeToURL:urlPath atomically:YES];
    
    NSLog(@"%lu", (unsigned long)dict.count);
    
}

- (void)loadFromPersistentStore
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *artistKey = @"artist";
    NSString *artistPath = [self filePath];
    
    if ([fileManager fileExistsAtPath:artistPath])
    {
        NSLog(@"file Exists at Path");
        NSURL *urlPath = [NSURL fileURLWithPath:artistPath];
        NSData *data = [NSData dataWithContentsOfURL:urlPath];
        NSError *error = nil;
        NSMutableDictionary *artistDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSArray *artistArray = artistDict[artistKey];
        for (NSMutableDictionary *dict in artistArray)
        {
            Artist *artist = [[Artist alloc] initWithDictionary:dict];
            [self.artists addObject:artist];
        }
        NSLog(@"Number Count Load Dict: %lu", (unsigned long)artistDict.count);
    } else {
        NSLog(@"File does not exist at path");
    }
    
}

@end
