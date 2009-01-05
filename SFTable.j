//
//  SFTable.j
//  XYZRadio
//
//  Created by Alos on 10/2/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>

@implementation SFTable : CPView
{
    /*Para las tablas*/
    CPCollectionView collectionView;
    CPArray model;
    /*Cosas para los titulos*/
    CPArray columnModel;
    /*Cosas para las celdas*/
    SFCell celdas;
    int pos=0; 
}

-(void) initWithColumnModel:(CPArray)aColumnModel model:(CPArray)aModel frame:(CGRect)bounds{
    self = [super initWithFrame:bounds];
    [self setModel:aModel];
    //para nuestro grid
    collectionView = [[CPCollectionView alloc] initWithFrame: CGRectMake(0, 19,  CGRectGetWidth(bounds), CGRectGetHeight(bounds)-19)];
    
    //los scrolls por si son muchos
    var scrollView = [[CPScrollView alloc] initWithFrame: CGRectMake(0, 19, CGRectGetWidth(bounds), CGRectGetHeight(bounds)-19-59)];
    [scrollView setAutohidesScrollers: NO];
    [scrollView setDocumentView: collectionView]; 
    [[scrollView contentView] setBackgroundColor: NULL];
    [scrollView setHasHorizontalScroller:NO];
    [scrollView setHasVerticalScroller:YES]
    [scrollView setAutoresizesSubviews:YES];
    [scrollView setAutoresizingMask: CPViewHeightSizable];
    //los items q representan los renglones
    var listItem = [[CPCollectionViewItem alloc] init];
    celdas = [[SFCell alloc] initWithFrame:CPRectCreateCopy([self bounds])];
    [listItem setView: celdas];  
    
    [collectionView setItemPrototype: listItem];  
    [collectionView setMaxNumberOfColumns:1]; 
    [collectionView setVerticalMargin:0.0];
    [collectionView setMinItemSize:CPSizeMake(CGRectGetWidth(bounds), 19)];
    [collectionView setMaxItemSize:CPSizeMake(CGRectGetWidth(bounds), 19)];
    [collectionView setContent: model];
    [collectionView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];
    [self addSubview:scrollView];
    
    
    //DELEGATE?
    [collectionView setDelegate: self];
        
    //la q esta arriba del Collectionview
    var borderArriba = [[CPView alloc] initWithFrame:CGRectMake(0, 19 , CGRectGetWidth(bounds), 0)];    
        [borderArriba setBackgroundColor: [CPColor grayColor]];
        //[borderArriba setAutoresizingMask: CPViewWidthSizable];
        [self addSubview: borderArriba];
    //la de arriba    
    var borderTop = [[CPView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bounds), 0)];    
        [borderTop setBackgroundColor: [CPColor grayColor]];
        //[borderTop setAutoresizingMask: CPViewWidthSizable];
        [self addSubview: borderTop];

    [self setColumnModel:aColumnModel];
    
    //[self registerForDraggedTypes:[SongsDragType]];
    
    return self;
}

-(void)collectionViewDidChangeSelection:(CPCollectionView)view
{
    if (view == collectionView)
    {
        var listIndex = [[collectionView selectionIndexes] firstIndex],
            key = [collectionView content][listIndex];
            
        var url = model[listIndex]["url"];
        CPLog(url);
        var info = [CPDictionary dictionaryWithObject:model[listIndex] forKey:"song"];   
	    [[CPNotificationCenter defaultCenter] postNotificationName:"setSong" object:self userInfo:info]; 
	    CPLog("posted notification");

    }
}

-(void)setColumnModel:(CPArray)aColumnModel{
    pos = 0;
    columnModel = aColumnModel;
    var oldWidth;
    for(var i=0; i<[columnModel count];i++){
        var thisColumn = [columnModel objectAtIndex:i];
        [self addSubview: thisColumn];
        if(i>0 && i<[columnModel count]){
            pos= pos+CGRectGetWidth([[columnModel objectAtIndex: i-1] bounds])+1;
            var border = [[CPView alloc] initWithFrame:CGRectMake(pos, 0, 1, CGRectGetHeight([self bounds]))];    
            CPLog("Setting line at: %d",pos);
            [border setBackgroundColor: [CPColor grayColor]];
            [border setAutoresizingMask: CPViewHeightSizable];
            [self addSubview: border];
        }
        
    }
}
-(void)setModel:(CPArray)aModel{
    model = aModel;
    [collectionView setContent: model];
    [collectionView reloadContent];
}
/**
Adds an item to the table
@param the item to add to the table
*/
-(void)addItem:(CPObject)anItem{
    [model addObject:anItem];
//    [collectionView setModel: model];
    [collectionView reloadContent];
}
/**
@param anIndex the value where the item you want t remove is
*/
-(void)removeItem:(int)anIndex{
    [model removeObjectAtIndex: anIndex];
    [collectionView reloadContent];
}
/**
Returns the item that is currently selected
@return
*/
-(int)getSelectedItem{
    return [[collectionView selectionIndexes] firstIndex];
}
-(id)objectAtIndex:(int)index
{
    return model[index];
}
/**
Removes selected items
*/
-(void)removeSelectedItems{
    CPLog("removeSelectedItems in SFTable got the msg");
    var indexes= [collectionView selectionIndexes];
    var a = [indexes firstIndex];
    [model removeObjectAtIndex: a];
    [collectionView reloadContent];
}
-(CPIndexSet)getSelectedItems{
    return [collectionView selectionIndexes];
}

-(void)reload
{
    [collectionView reloadContent];
}
/*-(CPArray)collectionView:(CPCollectionView)collectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices{
    return [SongsDragType];
}*/

- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indexes forType:(CPString)aType
{
    var index = CPNotFound,
        content = [aCollectionView content],
        songs = [];

    while ((index = [indexes indexGreaterThanIndex:index]) != CPNotFound)
        songs.push(content[index]);
    
    return [CPKeyedArchiver archivedDataWithRootObject:songs];
}

@end

@implementation SFCell : CPView
{
    CPTextField     titleView;
    CPTextField     authorView;
    CPTextField     albumView;
    CPTextField     time;
    CPTextField     filesize;
    CPView          highlightView;
    var theSong;
    CPPasteboard aPasteboard;
}

- (void)setRepresentedObject:(JSObject)anObject
{
    //CPLog("object is: " + [anObject description]);
    var cellPos = (CPRectGetWidth([self bounds]) - 150)/3;
    //CPLog("cell pos: " + CPRectGetWidth([self frame]));
    theSong = anObject;
    CPLog("Here");
    if(!titleView)
    {   
        titleView = [[CPTextField alloc] initWithFrame:CGRectInset( [self bounds], 0, 0)];
        [titleView setFont: [CPFont systemFontOfSize: 12.0]];
        [titleView setTextColor: [CPColor blackColor]];
        [self addSubview: titleView];
    }
    CPLog("here 2");
    CPLog(theSong["name"]);
    [titleView setStringValue: theSong["name"]];
    CPLog("here 3");
    [titleView setAutoresizingMask: CPViewWidthSizable | CPViewMinXMargin | CPViewMaxXMargin];
    [titleView sizeToFit];
    [titleView setFrameOrigin: CGPointMake(5,0.0)];
    
    if(!authorView)
    {
        authorView = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 0, 0)];
        [authorView setFont: [CPFont systemFontOfSize: 12.0]];
        [authorView setTextColor: [CPColor blackColor]];
        [self addSubview: authorView];
    }
    [authorView setStringValue: theSong["Artist"]];
    [authorView setAutoresizingMask: CPViewWidthSizable | CPViewMinXMargin | CPViewMaxXMargin];
    [authorView sizeToFit];
    [authorView setFrameOrigin: CGPointMake(cellPos+5,0.0)];//251
    
    if(!albumView)
    {
        albumView = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 0, 0)];
        [albumView setFont: [CPFont systemFontOfSize: 12.0]];
        [albumView setTextColor: [CPColor blackColor]];
        [self addSubview: albumView];
    }
    [albumView setStringValue: theSong["Album"]];
    [albumView setAutoresizingMask: CPViewWidthSizable | CPViewMinXMargin | CPViewMaxXMargin];
    [albumView sizeToFit];
    [albumView setFrameOrigin: CGPointMake((cellPos*2)+5,0.0)];   
   
    
    if(!time)
    {
        time = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 0, 0)];
        [time setFont: [CPFont systemFontOfSize: 12.0]];
        [time setTextColor: [CPColor blackColor]];
        [self addSubview: time];
    }
    [time setStringValue: [self getTime:theSong["Time"]]];
    [time setAutoresizingMask: CPViewWidthSizable | CPViewMinXMargin | CPViewMaxXMargin];
    [time sizeToFit];
    [time setFrameOrigin: CGPointMake(CPRectGetWidth([self bounds])-145,0.0)];
    
    CPLog("filesize");
    
    if(!filesize)
    {
        filesize = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 0, 0)];
        [filesize setFont: [CPFont systemFontOfSize: 12.0]];
        [filesize setTextColor: [CPColor blackColor]];
        [self addSubview: filesize];
    }
    CPLog("here 4");
    [filesize setStringValue:[self getFileSize:theSong["Size"]]];
    CPLog("here 5");
    [filesize setAutoresizingMask: CPViewWidthSizable | CPViewMinXMargin | CPViewMaxXMargin];
    [filesize sizeToFit];
    [filesize setFrameOrigin: CGPointMake(CPRectGetWidth([self bounds])-95,0.0)];
    CPLog("what");
    //CPLog(theSong["Color"]);
    if(theSong["Color"] == 0)
    {
        //CPLog(theSong["Color"]);
        [self setBackgroundColor:[CPColor colorWithCalibratedRed:213.0/255.0 green:221.0/255.0 blue:230.0/255.0 alpha:1.0]];
    }
    else
    {
        [self setBackgroundColor:[CPColor whiteColor]];
    }
     
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
        [self addSubview:highlightView positioned:CPWindowBelow relativeTo: titleView];
        [titleView setTextColor: [CPColor whiteColor]];
        [authorView setTextColor: [CPColor whiteColor]];
        [albumView setTextColor: [CPColor whiteColor]];
        [time setTextColor: [CPColor whiteColor]];
        [filesize setTextColor: [CPColor whiteColor]];
        
    }
    else
    {
        [highlightView removeFromSuperview];
        [titleView setTextColor: [CPColor blackColor]];            
        [authorView setTextColor: [CPColor blackColor]];
        [albumView setTextColor: [CPColor blackColor]];
        [time setTextColor: [CPColor blackColor]];     
        [filesize setTextColor: [CPColor blackColor]];

    }

}

-(CPString)getTime:(int)timeInMilis{
	var nSec = Math.floor(timeInMilis/1000);
    var min = Math.floor(nSec/60);
    var sec = nSec-(min*60);
    if (min == 0 && sec == 0) return null; // return 0:00 as null
	if(sec>=10)
		return min+":"+sec;
	else
		return min+":0"+sec;
}

-(CPString)getFileSize:(int)sizeInBytes{
    return (Math.round(sizeInBytes/1048576*100000)/100000).toFixed(1) + " MB";
}

@end
