
@interface Settings : NSObject {	
	NSArray *languages;
	NSMutableArray* downloads;  
	float brightness;
}

+ (Settings*)instance;

-(void)load;
-(void)save;

@property(nonatomic, retain) NSArray* languages;
@property(nonatomic, retain) NSMutableArray* downloads;
@property(assign) float brightness;


 
@end
