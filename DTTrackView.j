@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import "DTScrollingTextField.j"

@implementation DTTrackView : CPView
{   
    CPView noSongView;
    
    CPTextField _name;
    CPTextField artistAlbum;
    //CPTextField artist;
    //CPTextField album;
    CPSlider timeSlider;
    int totalTime;
}

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];
    [self setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:"Resources/realTrackBG.png?user=Guest&pass=" size:CPSizeMake(400, 46)]]];
    
    _name = [aCoder decodeObjectForKey:"name"];
    artistAlbum = [aCoder decodeObjectForKey:"artistAlbum"];
    console.log(artistAlbum);
    //artist = [aCoder decodeObjectForKey:"artist"];
    //album = [aCoder decodeObjectForKey:"album"];
    timeSlider = [[CPSlider alloc] initWithFrame:CGRectMake(CGRectGetWidth([self bounds])/2.0-145, CGRectGetHeight([self bounds])/2.0+8, CGRectGetWidth([self bounds]) - 105, 16)];
    [timeSlider setValue:[aCoder decodeObjectForKey:"timeSlider"]];
    noSongView = [aCoder decodeObjectForKey:"noSongView"];
    CPLog("time slider is " +timeSlider);
    totalTime = [[aCoder decodeObjectForKey:"totalTime"] intValue];
    [self setNoSongView:YES];
    
    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];
        
   [aCoder encodeObject:_name forKey:"name"];
   console.log(artistAlbum);
   [aCoder encodeObject:artistAlbum forKey:"artistAlbum"];
   //[aCoder encodeObject:artist forKey:"artist"];
   //[aCoder encodeObject:album forKey:"album"];
   [aCoder encodeObject:timeSlider forKey:"timeSlider"];
   [aCoder encodeObject:noSongView forKey:"noSongView"];
   [aCoder encodeObject:[CPNumber numberWithInt:totalTime] forKey:"totalTime"];//[CPNumber numberWithInt:
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    [self setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:"Resources/realTrackBG.png?user=Guest&pass=" size:CPSizeMake(400, 46)]]];
    
    noSongView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
    [noSongView setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:"Resources/noSongBG.png" size:CPSizeMake(400, 50)]]];
    //[self addSubview:noSongView positioned:CPWindowAbove relativeTo:nil];
    [self setNoSongView:YES];
    
    _name = [[CPTextField alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(aFrame)/2.0-24, CGRectGetWidth(aFrame), 16)];
    [_name setAlignment:CPCenterTextAlignment];
    artistAlbum = [[DTScrollingTextField alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(aFrame)/2.0-8, CGRectGetWidth(aFrame), 16)];
    console.log(artistAlbum);
    [artistAlbum setAlignment:CPCenterTextAlignment];
    //artist = [[CPTextField alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(aFrame)/2.0 - 16, CGRectGetWidth(aFrame), 16)];
    //[artist setAlignment:CPCenterTextAlignment];
    //album = [[CPTextField alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(aFrame)/2.0 - 6, CGRectGetWidth(aFrame), 16)];
    //[album setAlignment:CPCenterTextAlignment];
    timeSlider = [[CPSlider alloc] initWithFrame:CGRectMake(CGRectGetWidth(aFrame)/2.0-145, CGRectGetHeight(aFrame)/2.0-4, CGRectGetWidth(aFrame) - 105, 16)];
    [timeSlider setTarget:self];
    [timeSlider setAction: @selector(sliderChangedValue:)];
    [timeSlider setMinValue:0.0];
    [timeSlider setMinValue:100.0];
    [timeSlider setValue:30.0];
    totalTime = 0;
    
    [_name setStringValue:"name"];
    [artistAlbum setStringValue:"artist \n album"];
    //[artist setStringValue:"artist"];
    //[album setStringValue:"album"];

    return self;
}	

-(void)setSong:(Object)aSong
{
    CPLog("got it");
    [self setNoSongView:NO];
	
	[_name setStringValue:aSong["name"]];
	[artistAlbum setStringValue:aSong["Artist"] + "\n" + aSong["Album"]];
	[artistAlbum start];
	//[artist setStringValue:aSong["Artist"]];
	//[album setStringValue:aSong["Album"]];
	[self setNeedsDisplay:YES];
	totalTime = aSong["Time"];
}

-(void)setTime:(int)timeInMilis{
    CPLog("milis: " + timeInMilis);
    CPLog("setting position");
    CPLog("total time: " + totalTime);
	var currTime = (timeInMilis*100)/totalTime;
	CPLog("time: " + currTime);
	if(currTime==NULL)
		return;
		
	if([timeSlider respondsToSelector:@selector(setValue:)])
	   CPLog("I cna!");
	   
	[timeSlider setValue:currTime];
	CPLog("time slider is now: " + [timeSlider value]);
	[timeSlider setNeedsDisplay:YES];
}

- (void)sliderChangedValue:(id)sender
{
    var newTime = (100*[timeSlider value])/totalTime;
    var info = [CPDictionary dictionaryWithObject:newTime forKey:"pos"];
    [[CPNotificationCenter defaultCenter] postNotificationName:"changePos" object:self userInfo:info];
}

-(void)setNoSongView:(BOOL)b
{
    if(b)
    {
        [self addSubview:noSongView];
        [_name removeFromSuperview];
        [artistAlbum removeFromSuperview];
        //[artist removeFromSuperview];
        //[album removeFromSuperview];
        [timeSlider removeFromSuperview];
    }
    else
    {
        [noSongView removeFromSuperview];
        [self addSubview:_name];
        console.log(artistAlbum);
        [self addSubview:artistAlbum];
        //[self addSubview:artist];
        //[self addSubview:album];
        [self addSubview:timeSlider];
    }
}

@end

/*@implementation timeSliderView : CPSlider
{
}

-(id)initWithFrame:(CGFrame)aFrame
{
	[super initWithFrame:aFrame];
	//_bar = [[CPView alloc] initWithFrame:CGRectMake];
	//var _barIcon = [[CPImage alloc] initWithContentsOfFile:"Resources/barIcon.tiff"];
	//[_bar addSubview:_barIcon];
}

-(void)mouseDown:(CPEvent)aEvent
{
}

@end*/