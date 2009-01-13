@import <Foundation/CPURLRequest.j>
@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>

@implementation DTArtistTable : CPView
{
    CPCollectionView letterView;
    CPURLConnection letterConnection;
    CPCollectionView artistView;
    CPURLConnection artistConnection;
    CPCollectionView albumView;
    CPArray model;
    var selectedArtist;
}

-(id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];   
    
    model = nil;   
        
    var letterScrollView = [[CPScrollView alloc] initWithFrame: CGRectMake(0, 0, CGRectGetWidth(aFrame)/3, CGRectGetHeight(aFrame))];
    [letterScrollView setAutohidesScrollers: YES];
    [letterScrollView setHasHorizontalScroller:NO];
    [letterScrollView setAutoresizingMask: CPViewHeightSizable];
        
    var letterViewItem = [[CPCollectionViewItem alloc] init];
    [letterViewItem setView: [[ArtistTableCell alloc] initWithFrame:CGRectMakeZero()]];

    letterView = [[CPCollectionView alloc] initWithFrame: CGRectMake(0, 0, CGRectGetWidth(aFrame)/3, CGRectGetHeight(aFrame))];

    [letterView setDelegate: self];
    [letterView setItemPrototype: letterViewItem];
    
    [letterView setMinItemSize:CPSizeMake(CGRectGetWidth(aFrame)/3, 19)];
    [letterView setMaxItemSize:CPSizeMake(CGRectGetWidth(aFrame)/3, 19)];
    [letterView setMaxNumberOfColumns:1];
    
    [letterView setVerticalMargin:0.0];
    [letterView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];

    [letterScrollView setDocumentView: letterView];        
    //[[letterScrollView contentView] setBackgroundColor: [CPColor colorWithCalibratedRed:213.0/255.0 green:221.0/255.0 blue:230.0/255.0 alpha:1.0]];

    [self addSubview: letterScrollView];
    
    [letterView setContent:[CPArray arrayWithObjects:"All", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K","L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", nil]];
    
    var artistScrollView = [[CPScrollView alloc] initWithFrame: CGRectMake(CGRectGetWidth(aFrame)/3, 0, CGRectGetWidth(aFrame)/3, CGRectGetHeight(aFrame))];
    [artistScrollView setAutohidesScrollers: NO];
    [artistScrollView setHasHorizontalScroller:NO];
    [artistScrollView setAutoresizingMask: CPViewHeightSizable];
        
    var artistViewItem = [[CPCollectionViewItem alloc] init];
    [artistViewItem setView: [[ArtistTableCell alloc] initWithFrame:CGRectMakeZero()]];

    artistView = [[CPCollectionView alloc] initWithFrame: CGRectMake((CGRectGetWidth(aFrame)/3)*2, 0, CGRectGetWidth(aFrame)/3, CGRectGetHeight(aFrame))];

    [artistView setDelegate: self];
    [artistView setItemPrototype: artistViewItem];
    
    [artistView setMinItemSize:CPSizeMake(CGRectGetWidth(aFrame)/3, 19)];
    [artistView setMaxItemSize:CPSizeMake(CGRectGetWidth(aFrame)/3, 19)];
    [artistView setMaxNumberOfColumns:1];
    
    [artistView setVerticalMargin:0.0];
    [artistView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];

    [artistScrollView setDocumentView: artistView];        
    //[[artistScrollView contentView] setBackgroundColor: [CPColor colorWithCalibratedRed:213.0/255.0 green:221.0/255.0 blue:230.0/255.0 alpha:1.0]];

    [self addSubview: artistScrollView]; 
    
    var noArtistArray = [CPMutableArray array];
    [noArtistArray addObject:"Please select a letter..."];
    [artistView setContent:noArtistArray];
    [artistView reloadContent];
    
    var albumScrollView = [[CPScrollView alloc] initWithFrame: CGRectMake(CGRectGetWidth(aFrame)-CGRectGetWidth(aFrame)/3, 0, CGRectGetWidth(aFrame)/3, CGRectGetHeight(aFrame))];
    [albumScrollView setAutohidesScrollers: NO];
    [albumScrollView setHasHorizontalScroller:NO];
    [albumScrollView setAutoresizingMask: CPViewHeightSizable];
        
    var albumViewItem = [[CPCollectionViewItem alloc] init];
    [albumViewItem setView: [[ArtistTableCell alloc] initWithFrame:CGRectMakeZero()]];

    albumView = [[CPCollectionView alloc] initWithFrame: CGRectMake((CGRectGetWidth(aFrame)/3)*3, 0, CGRectGetWidth(aFrame)/3, CGRectGetHeight(aFrame))];

    [albumView setDelegate: self];
    [albumView setItemPrototype: albumViewItem];
    
    [albumView setMinItemSize:CPSizeMake(CGRectGetWidth(aFrame)/3, 19)];
    [albumView setMaxItemSize:CPSizeMake(CGRectGetWidth(aFrame)/3, 19)];
    [albumView setMaxNumberOfColumns:1];
    
    [albumView setVerticalMargin:0.0];
    [albumView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];

    [albumScrollView setDocumentView: albumView];        
    //[[albumScrollView contentView] setBackgroundColor: [CPColor colorWithCalibratedRed:213.0/255.0 green:221.0/255.0 blue:230.0/255.0 alpha:1.0]];

    [self addSubview: albumScrollView];  
    
    var noAlbumArray = [CPMutableArray array];
    [noAlbumArray addObject:"Please select an artist..."];
    [albumView setContent:noAlbumArray];
    [albumView reloadContent];
    
    return self;
}

-(void)setModel:(CPArray)aModel
{
    model = aModel;
}

-(void)collectionViewDidChangeSelection:(CPCollectionView)view
{
    var listIndex = [[view selectionIndexes] firstIndex],
            key = [view content][listIndex];
            
    CPLog(key);
    
    if (view == letterView)
    {
        CPLog("LETTER VIEW");
        if(model != nil)
        {
            CPLog("model not nil");
            [artistView setContent:nil];
            [artistView setContent:[self parseModelFor:"Letter" value:key]];
            [artistView reloadContent];
        }
        else
        {
            letterConnection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:"/index.php?username=Guest&password=&action=render&render=Artists.php&letter=" + key] delegate:self startImmediately:NO];
            [letterConnection start];
        }
    }
    if(view == artistView)
    {
        if(model != nil)
        {
            [albumView setContent:nil];
            [albumView setContent:[self parseModelFor:"Artist" value:key]];
            [albumView reloadContent];
        }
        else
        {
            artistConnection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:"/index.php?username=Guest&password=&action=render&render=ArtistAlbums.php&Artist=" + key] delegate:self startImmediately:NO];
            [artistConnection start];
        }
        selectedArtist = key;
        [[CPNotificationCenter defaultCenter] postNotificationName:"ChangeArtist" object:self userInfo:[CPDictionary dictionaryWithObject:key forKey:"Artist"]];
    }
    if(view == albumView)
    {
        var info = [CPDictionary dictionary];
        [info setObject:selectedArtist forKey:"Artist"];
        [info setObject:key forKey:"Album"];
        [[CPNotificationCenter defaultCenter] postNotificationName:"ChangeAlbum" object:self userInfo:info];
    }
}

- (CPArray)parseModelFor:(CPString)mode value:(CPString)v
{
    var newContent = [CPMutableArray array];
    if(mode == "Letter")//Letter return artist
    {
        CPLog("lettah");
        CPLog(model);
        CPLog([model objectAtIndex:0]["Artist"]);
        for(i=0; i<[model count]; i++)
        {
            if([model objectAtIndex:i]["Artist"].substring(0,1) == v && [newContent indexOfObject:[model objectAtIndex:i]["Artist"]] == -1)
            {
                //CPLog([model[i] description]);[
                [newContent addObject:[model objectAtIndex:i]["Artist"]];
                CPLog("I am here");
            }
        }
        
        CPLog("new content is: " + newContent);
    }
    else if(mode == "Artist")
    {
        for(i=0; i<[model count]; i++)
        {
            CPLog([newContent indexOfObject:[model objectAtIndex:i]["Album"]]);
            if([model objectAtIndex:i]["Artist"] == v && [newContent indexOfObject:[model objectAtIndex:i]["Album"]] == -1)
                [newContent addObject:[model objectAtIndex:i]["Album"]];
        }
    }
    else
        CPLog("invalid mode");
        
    CPLog(newContent);
        
    return newContent;
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)data
{
    var newContent = [CPMutableArray array];
    
    if (aConnection == letterConnection)
    {
        try
        {
           var result = CPJSObjectCreateWithJSON(data);
           CPLog(result);
           var i;
           for(i in result)
           {
                if(result[i]["Artist"] != nil)
                    [newContent addObject:result[i]["Artist"]];
            }
            [artistView setContent:nil];
            [artistView setContent:newContent];
            [artistView reloadContent];
            letterConnection = nil;
        }
        catch(e)
        {
            CPLog("Error");
            return [self connection:aConnection didFailWithError: e];
        }
    }
    if (aConnection == artistConnection)
    {
        try
        {
           var result = CPJSObjectCreateWithJSON(data);
           CPLog(result);
           var x;
           for(x in result)
            {
                CPLog(result[x]["Album"]);
                if(result[x]["Album"] != nil)
                    [newContent addObject:result[x]["Album"]];
            }
            [albumView setContent:nil];
            [albumView setContent:newContent];
            [albumView reloadContent];
            artistConnection = nil;
        }
        catch(e)
        {
            CPLog("Error");
            return [self connection:aConnection didFailWithError: e];
        }
    }
}
 
- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    CPLog(anError);
    [self connectionDidFinishLoading:aConnection];
}
 
- (void)connectionDidFinishLoading:(CPURLConnection)aConnection
{
    if (aConnection == letterConnection)
    {
        letterConnection = nil;
    }
    if(aConnection == artistConnection)
    {
        artistConnection = nil;
    }
}

@end
    
@implementation ArtistTableCell : CPView
{
    CPTextField     label;
    CPView          highlightView;
}

- (void)setRepresentedObject:(JSObject)anObject
{
    CPLog("The item is: " + anObject);
    //if(label || anObject == nil) label= nil;
    if(!label)
    {
    
        label = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 0, 0)];
        
        [label setFont: [CPFont systemFontOfSize: 12.0]];
        [label setTextColor: [CPColor blackColor]];
        
        [self addSubview: label]
        
    }
    else
    {
        CPLog("item " + anObject + "exists");
    } 
    [label setStringValue: anObject];
    [label sizeToFit];

    [label setFrameOrigin: CGPointMake(CPRectGetWidth([self bounds])+10,0.0)];
}

- (void)setSelected:(BOOL)flag
{
    if(!highlightView)
    {
        highlightView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
        [highlightView setBackgroundColor: [CPColor blueColor]];
    }

    if(flag)
    {
        [self addSubview:highlightView positioned:CPWindowBelow relativeTo: label];
        [label setTextColor: [CPColor whiteColor]];    
    }
    else
    {
        [highlightView removeFromSuperview];
        [label setTextColor: [CPColor blackColor]];
    }
}

@end