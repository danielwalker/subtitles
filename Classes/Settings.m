#import "Settings.h"

static Settings *instance;

@implementation Settings;

@synthesize languages, brightness, downloads;

+ (Settings *)instance{
    @synchronized(self){
        if (instance == NULL) {				
            instance = [[self alloc] init];
		}
    }
    return(instance);
}

- (id) init {
	self = [super init];
	if (self) {	
		[self load];		
	}	
	return self;
}

-(void)load {		
	NSUserDefaults *data = [NSUserDefaults standardUserDefaults];		
	[data registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0f], @"brightness", nil]];	
	
	NSData *entriedData = [data objectForKey:@"languages"];
	if(entriedData != nil) {
		self.languages = [NSKeyedUnarchiver unarchiveObjectWithData:entriedData]; 				
	}		
	
	entriedData = [data objectForKey:@"downloads"];
	if(entriedData != nil) {
		self.downloads = [NSKeyedUnarchiver unarchiveObjectWithData:entriedData]; 				
	} else {
		self.downloads = [[[NSMutableArray alloc] init] autorelease];	
	}
	
	self.brightness = [data floatForKey:@"brightness"]; 		 	
}

-(void)save {
	NSUserDefaults *data = [NSUserDefaults standardUserDefaults];					
	NSData *archived = [NSKeyedArchiver archivedDataWithRootObject:languages];		
	[data setObject:archived forKey: @"languages"];	
	
	archived = [NSKeyedArchiver archivedDataWithRootObject:downloads];		
	[data setObject:archived forKey: @"downloads"];	
	
	[data setFloat:brightness forKey:@"brightness"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) dealloc {
	[languages release];
	[downloads release];
	[super dealloc];
}


@end
