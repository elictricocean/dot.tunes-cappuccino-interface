//
//  AppController.h
//  ¬´PROJECTNAME¬ª
//
//  Created by ¬´FULLUSERNAME¬ª on ¬´DATE¬ª.
//  Copyright ¬´ORGANIZATIONNAME¬ª ¬´YEAR¬ª. All rights reserved.
//


@import <Foundation/CPURLRequest.j>
@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import <AppKit/CPFlashView.j>
@import <AppKit/CPFlashMovie.j>
@import "/shared/CPQuicktimeController.j?user=Guest&pass="
//@import "/shared/SMSoundManager.j?user=Guest&pass="
@import "/shared/DTTrackView.j?user=Guest&pass="
@import "/shared/DTArtistTable.j?user=Guest&pass="
@import "/shared/DTSegmentedControl.j?user=Guest&pass="
@import "/shared/SFTable.j?user=Guest&pass="
@import "/shared/SFColumnModel.j?user=Guest&pass="

var previousTrackItemIdentifier = "previousTrackItemIdentifier",
	playPauseItemIdentifier = "playPauseItemIdentifier",
	nextTrackItemIdentifier = "nextTrackItemIdentifier",
	volumeItemIdentifier = "volumeItemIdentifier",
	trackItemIdentifier = "trackItemIdentifier",
	viewItemIdentifier = "viewItemIdentifier",
	searchViewItemIdentifier = "searchViewItemIdentifier";
	
var theAppControl;

@implementation AppController : CPObject
{
    CPWindow theWindow;
    
    CPDictionary playlists;
    
    CPURLConnection connection;
    CPURLConnection playlistConnection;
    CPURLConnection searchConnection;
    CPURLConnection artistConnection;
    CPURLConnection albumConnection;
    var searchQuery;
    var playlistName;
    var artistQuery;
    var albumQuery;
    
    var sessionEndedErrorWindow;

	CPCollectionView playlistCollectionView;
	SFTable libraryTable;
	CPArray libraryTableModel;
	
    DTArtistTable artistTableView;
    BOOL artistTableViewEnabled;
    CPFlashView flashView;
    CPString flashURL;
    BOOL flashEnabled;
    
    CPQuicktimeController QT;
    //SMSoundManager theSoundManager;
    BOOL isSongLoaded;
    BOOL isPaused;
    int nextTrack;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    CPLogRegister(CPLogPopup);
    theAppControl = self;
    playlists = [CPDictionary dictionary];
     
    theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];
    var contentView = [theWindow contentView],
        toolbar = [[CPToolbar alloc] initWithIdentifier:"DT Toolbar"];
        
    var bounds = [contentView bounds];
      
    QT = [[CPQuicktimeController alloc] initWithContentsOfFile:"nope.mp3" identifier:nil]; //ContentsOfFile:"nope.mp3" i
    window.QTPlayer = QT;    
    //theSoundManager = [[SMSoundManager alloc] init];
    isSongLoaded = NO;
    isPaused = YES;
    
    artistTableView = [[DTArtistTable alloc] initWithFrame:CGRectMake(200, 0, CGRectGetWidth([[theWindow contentView] bounds]) - 200, 300)];
    artistTableViewEnabled = NO;
    
    flashView = [[CPFlashView alloc] initWithFrame:CPRectMake(200, 0, CGRectGetWidth(bounds) - 200, 300)];
    [flashView setAutoresizingMask: CPViewWidthSizable];
    flashURL = nil;
    flashEnabled = NO;
    
    [toolbar setDelegate:self];
	[toolbar setVisible:true];
	[toolbar setDisplayMode:CPToolbarDisplayModeIconOnly];

	[theWindow setToolbar:toolbar];
	[theWindow setTitle:"DOT.TUNES"];
	var mainMenu = [[CPMenu alloc] initWithTitle:"DOT.TUNES"];
	var fileItem = [[CPMenuItem alloc] initWithTitle:"File" action:nil keyEquivalent:nil];
	var fileMenu = [[CPMenu alloc] initWithTitle:"fileMenu"];
	[fileMenu addItemWithTitle:"Shuffle songs in table" action:nil keyEquivalent:"b"];
	[fileMenu addItem:[CPMenuItem separatorItem]];
	[fileMenu addItemWithTitle:"Bookmark current song..." action:nil keyEquivalent:"b"];
	[fileMenu addItemWithTitle:"Remove bookmark current song..." action:nil keyEquivalent:nil];
	[fileMenu addItem:[CPMenuItem separatorItem]];
	[fileMenu addItemWithTitle:"Rate current song..." action:nil keyEquivalent:nil];//Admin
	[fileMenu addItem:[CPMenuItem separatorItem]];
	[fileMenu addItemWithTitle:"Download current song..." action:nil keyEquivalent:"d"];//if available
	[fileMenu addItemWithTitle:"Play currently playing song in owners iTunes..." action:nil keyEquivalent:nil];
	[fileItem setSubmenu:fileMenu];
	var shareItem = [[CPMenuItem alloc] initWithTitle:"Share" action:nil keyEquivalent:nil];
	var shareMenu = [[CPMenu alloc] initWithTitle:"shareMenu"];
	[shareMenu addItemWithTitle:"RSS feed for songs in table..." action:nil keyEquivalent:"r"];
	[shareMenu addItemWithTitle:"Podcast for songs in table..." action:nil keyEquivalent:"p"];
	[shareMenu addItemWithTitle:"M3U for songs in table..." action:nil keyEquivalent:"p"];
	[shareMenu addItem:[CPMenuItem separatorItem]];
	[shareMenu addItemWithTitle:"Setup flash player" action:nil keyEquivalent:nil];
	[shareItem setSubmenu:shareMenu];
	[mainMenu addItem:fileItem];
	[mainMenu addItem:shareItem]; 
	[[CPApplication sharedApplication] setMainMenu:mainMenu];
	
	var listScrollView = [[CPScrollView alloc] initWithFrame: CGRectMake(0, 0, 199, CGRectGetHeight(bounds)-59)];
    [listScrollView setAutohidesScrollers: YES];
    [listScrollView setAutoresizingMask: CPViewHeightSizable];
        
    var photosListItem = [[CPCollectionViewItem alloc] init];
    [photosListItem setView: [[PlayListCell alloc] initWithFrame:CGRectMakeZero()]];

    playlistCollectionView = [[CPCollectionView alloc] initWithFrame: CGRectMake(0, 0, 199, CGRectGetHeight(bounds))];

    [playlistCollectionView setDelegate: self];
    [playlistCollectionView setItemPrototype: photosListItem];
    
    [playlistCollectionView setMinItemSize:CGSizeMake(20.0, 55.0/2.0)];
    [playlistCollectionView setMaxItemSize:CGSizeMake(1000.0, 55.0/2.0)];
    [playlistCollectionView setMaxNumberOfColumns:1];
    
    [playlistCollectionView setVerticalMargin:0.0];
    [playlistCollectionView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];

    [listScrollView setDocumentView: playlistCollectionView];        
    [[listScrollView contentView] setBackgroundColor: [CPColor colorWithCalibratedRed:213.0/255.0 green:221.0/255.0 blue:230.0/255.0 alpha:1.0]];

    [contentView addSubview: listScrollView];  
    
     //border
    var borderView = [[CPView alloc] initWithFrame:CGRectMake(199, 0, 1, CGRectGetHeight(bounds))];
    
    [borderView setBackgroundColor: [CPColor blackColor]];
    [borderView setAutoresizingMask: CPViewHeightSizable];
    
    [contentView addSubview: borderView];

    var cmArray = [[CPArray alloc] init]; 
    var titleLabel = [[SFColumnModel alloc] initWithFrame:CGRectMake(0, 0, (((CGRectGetWidth(bounds)-200-150)/3))+1, 19) title:" Name" color:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:"Resources/tableHeader.png" size:CPSizeMake(50, 19)]]];
    var artistLabel = [[SFColumnModel alloc] initWithFrame:CGRectMake(((CGRectGetWidth(bounds)-200)-150)/3, 0, ((CGRectGetWidth(bounds)-200-150)/3)+1, 19) title:" Artist" color: [CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:"Resources/tableHeader.png" size:CPSizeMake(50, 19)]]];//250
    var albumLabel = [[SFColumnModel alloc] initWithFrame:CGRectMake(((CGRectGetWidth(bounds)-200-150)/3)*2, 0, ((CGRectGetWidth(bounds)-200-150)/3), 19) title:" Album" color:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:"Resources/tableHeader.png" size:CPSizeMake(50, 19)]]];//500
    var timeLabel = [[SFColumnModel alloc] initWithFrame:CGRectMake((CGRectGetWidth(bounds)-200)-150, 0, 50, 19) title:" Time" color: [CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:"Resources/tableHeader.png" size:CPSizeMake(50, 19)]]];//750
    var filesizeLabel = [[SFColumnModel alloc] initWithFrame:CGRectMake((CGRectGetWidth(bounds)-200)-100, 0, 100, 19) title:" Size" color:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:"Resources/tableHeader.png"  size:CPSizeMake(50, 19)]]];//800  size:CPSizeMake(50, 19)
    [cmArray addObject: titleLabel];
    [cmArray addObject: artistLabel];
    [cmArray addObject: albumLabel];
    [cmArray addObject: timeLabel];
    [cmArray addObject: filesizeLabel];
    
    libraryTable = [[SFTable alloc] initWithColumnModel: cmArray model:[[CPArray alloc] init] frame: CGRectMake(200, 0, CGRectGetWidth(bounds) - 200, CGRectGetHeight(bounds))];
    [libraryTable setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];
        
    [contentView addSubview: libraryTable]; 
    [theWindow orderFront:self];
    
    [CPMenu setMenuBarVisible:YES];
    
    connection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:"/index.php?username=Guest&password=&action=render&render=Playlists.php"] delegate:self startImmediately:NO];
    [connection start];
    [self addPlaylist:"all" withName:"___all___"];
    
    sessionEndedErrorWindow = [[CPAlert alloc] init];
    [sessionEndedErrorWindow setMessageText:"Error your session has ended. \nPlease log in Again."];
    [sessionEndedErrorWindow setAlertStyle:CPCriticalAlertStyle];
    [sessionEndedErrorWindow addButtonWithTitle:"Ok"];
    [sessionEndedErrorWindow setDelegate:self];
    CPLog(sessionEndedErrorWindow.CPAlertErrorImage);
    
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(setSong:) name:"setSong" object:libraryTable];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(setTime:) name:"CPQuicktimeControllerTimeChanged" object:QT];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(changePos:) name:"changePos" object:[[[[theWindow toolbar] items] objectAtIndex:5] view]];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(songDidFinish:) name:"CPQuicktimeControllerEnded" object:QT];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(changeView:) name:"ChangeView" object:[[[[theWindow toolbar] items] objectAtIndex:7] view]];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(changeArtist:) name:"ChangeArtist" object:artistTableView];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAlbum:) name:"ChangeAlbum" object:artistTableView];
}

-(void)setAllMusicView
{
    libraryTableModel = nil;
        
    [[[[[theWindow toolbar] items] objectAtIndex:7] view] setSegmentWithName:"Artists"];
    //[self changeView:"Artists"];
}

- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
   return [previousTrackItemIdentifier, playPauseItemIdentifier, nextTrackItemIdentifier, volumeItemIdentifier, CPToolbarFlexibleSpaceItemIdentifier, trackItemIdentifier, CPToolbarFlexibleSpaceItemIdentifier, viewItemIdentifier, searchViewItemIdentifier];
}

- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return [previousTrackItemIdentifier, playPauseItemIdentifier, nextTrackItemIdentifier, volumeItemIdentifier, CPToolbarFlexibleSpaceItemIdentifier, trackItemIdentifier, CPToolbarFlexibleSpaceItemIdentifier, viewItemIdentifier, searchViewItemIdentifier];
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier: anItemIdentifier];

    if(anItemIdentifier == previousTrackItemIdentifier)
	{
		var image = [[CPImage alloc] initWithContentsOfFile:"Resources/BackwardEnabledActiveLeopard.tiff?user=Guest&pass=" size:CPSizeMake(41, 41)],
            highlighted = [[CPImage alloc] initWithContentsOfFile:"Resources/BackwardPressedActiveLeopard.tiff?user=Guest&pass=" size:CPSizeMake(41, 41)];
            
        [toolbarItem setImage: image];
        [toolbarItem setAlternateImage: highlighted];
        
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(previousTrack)];

        [toolbarItem setMinSize:CGSizeMake(41, 41)];
        [toolbarItem setMaxSize:CGSizeMake(41, 41)];
	}
	else if(anItemIdentifier == playPauseItemIdentifier)
	{
		var image = [[CPImage alloc] initWithContentsOfFile:"Resources/PlayEnabledActiveLeopard.tiff?user=Guest&pass=" size:CPSizeMake(45, 45)],
            highlighted = [[CPImage alloc] initWithContentsOfFile:"Resources/PlayPressedActiveLeopard.tiff?user=Guest&pass=" size:CPSizeMake(45, 45)];
            
        [toolbarItem setImage: image];
        [toolbarItem setAlternateImage: highlighted];
        
        [toolbarItem setTarget: self];//[[[aToolbar items] objectAtIndex:5] view]
        [toolbarItem setAction: @selector(playPauseSong)];

        [toolbarItem setMinSize:CGSizeMake(45, 45)];
        [toolbarItem setMaxSize:CGSizeMake(45, 45)];
	}
	else if(anItemIdentifier == nextTrackItemIdentifier)
	{
		var image = [[CPImage alloc] initWithContentsOfFile:"Resources/ForwardEnabledActiveLeopard.tiff?user=Guest&pass=" size:CPSizeMake(41, 41)],
            highlighted = [[CPImage alloc] initWithContentsOfFile:"Resources/ForwardPressedActiveLeopard.tiff?user=Guest&pass=" size:CPSizeMake(41, 41)];
            
        [toolbarItem setImage: image];
        [toolbarItem setAlternateImage: highlighted];
        
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(nextTrack)];

        [toolbarItem setMinSize:CGSizeMake(41, 41)];
        [toolbarItem setMaxSize:CGSizeMake(41, 41)];
	}
	else if(anItemIdentifier == volumeItemIdentifier)
    {
        [toolbarItem setView: [[volumeView alloc] initWithFrame:CGRectMake(0, 0, 180, 32)]];
        [toolbarItem setMinSize:CGSizeMake(180, 50)];//180 50
        [toolbarItem setMaxSize:CGSizeMake(180, 50)];
    }
    else if(anItemIdentifier == trackItemIdentifier)
    {
        [toolbarItem setView: [[DTTrackView alloc] initWithFrame:CGRectMake(0, 0, 400, 46)]];
        [toolbarItem setMinSize:CGSizeMake(400, 46)];
        [toolbarItem setMaxSize:CGSizeMake(400, 46)];
    }
    else if (anItemIdentifier == viewItemIdentifier)
    {        
        [toolbarItem setView: [[ViewWindowView alloc] initWithFrame:CGRectMake(0, 0, 77, 50)]];
        [toolbarItem setMinSize:CGSizeMake(180, 50)];
        [toolbarItem setMaxSize:CGSizeMake(180, 50)];
    }
	else if (anItemIdentifier == searchViewItemIdentifier)
    {        
        [toolbarItem setView: [[SearchView alloc] initWithFrame:CGRectMake(0, 0, 180, 50) target:self]];
        [toolbarItem setMinSize:CGSizeMake(180, 50)];
        [toolbarItem setMaxSize:CGSizeMake(180, 50)];
    }
    else
    {
        return nil;
    }
    
    return toolbarItem;
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)data
{
    CPLog("data is : " + data);
    
    if (connection == aConnection)
    {
        CPLog("hr,,");
        try
        {
            CPLog("Now");
            //CPLog([data description]);
            var result = CPJSObjectCreateWithJSON(data);
             //CPLog(result);
        }
        catch(e)
        {
            //CPLog("Error");
            return [self connection:aConnection didFailWithError: e];
        }
 
        // do stuff with result
        //CPLog([result description]);
        var x;
        for(x in result)
        {
           // alert(result[x]["Name"]);
            var name = result[x]["Name"];
            var url = result[x]["playlist_tracks_url"];
            [self addPlaylist:url withName:name];
        }
         var listIndex = [[playlistCollectionView selectionIndexes] firstIndex];
        CPLog(listIndex);   
        if (listIndex == -1)
        {
            CPLog("woo");
            [playlistCollectionView setSelectionIndexes:[CPIndexSet indexSetWithIndex:0]];
        }
        //[self setAllMusicView];
        connection = nil;
    }
    if(playlistConnection == aConnection)
    {
        CPLog("playlist connection");
        try
        {
            CPLog("Now");
            var result = CPJSObjectCreateWithJSON(data.replace(/\n/g, ""));
            //CPLog([result description]);
        }
        catch(e)
        {
            CPLog("Error");
            //CPLog(e);
            return [self connection:aConnection didFailWithError: e];
        }
 
        // do stuff with result
        //CPLog([result description]);
        [libraryTable setModel:result];
        
        libraryTableModel = result;
        if(artistTableViewEnabled)
            [self changeView:"Artists"];
            
        flashURL = "Resources/itunesartV5.swf?action=CoverBrowser&DTXml=/flash.html%3Faction=flashsearch%26user=Guest%26pass=%26s1=" + escape(playlistName) + "%26Type=Playlist%26CoverBrowse=true%26size=small%26ftype=any%26limit=50%26offset=0%26foo=bar.xml";
        if(flashEnabled)
            [self changeView:"Coverflow"];
        playlistConnection = nil;
    }
    if(searchConnection == aConnection)
    {
        //CPLog("search connection");
        try
        {
            //CPLog("Now");
            var result = CPJSObjectCreateWithJSON(data);
            //CPLog(result);
        }
        catch(e)
        {
            CPLog("Error");
            //CPLog("error is: ", e);
            return [self connection:aConnection didFailWithError: e];
        }
        
        [libraryTable setModel:result];
        searchConection = nil;
        
        libraryTableModel = result;
        if(artistTableViewEnabled)
            [self changeView:"Artists"];
           
        flashURL = "Resources/itunesartV5.swf?action=CoverBrowser&DTXml=/flash.html%3Faction=flashsearch%26id=fva3hdtn%26s1=" + escape(searchQuery) + "%26Type=All%26CoverBrowse=true%26size=small%26ftype=any%26limit=50%26offset=0%26foo=bar.xml";
        if(flashEnabled)
            [self changeView:"Coverflow"];
    }
    if(artistConnection == aConnection)
    {
        CPLog("artist connection");
        try
        {
            CPLog("Now");
            var result = CPJSObjectCreateWithJSON(data.replace(/\n/g, ""));
            CPLog([result description]);
        }
        catch(e)
        {
            CPLog("Error");
            //CPLog(e);
            return [self connection:aConnection didFailWithError: e];
        }
 
        // do stuff with result
        //CPLog([result description]);
        [libraryTable setModel:result];
        
        libraryTableModel = result;
        if(artistTableViewEnabled)
            [self changeView:"Artists"];
            
        flashURL = "Resources/itunesartV5.swf?action=CoverBrowser&DTXml=/flash.html%3Faction=flashsearch%26id=g4qok7in%26s1=" + escape(artistQuery) + "%26Type=Artist%26CoverBrowse=true%26size=small%26ftype=any%26limit=50%26offset=0%26foo=bar.xml";
        if(flashEnabled)
            [self changeView:"Coverflow"];
        playlistConnection = nil;
    }
    if(albumConnection == aConnection)
    {
        CPLog("album connection");
        try
        {
            CPLog("Now");
            var result = CPJSObjectCreateWithJSON(data.replace(/\n/g, ""));
            CPLog([result description]);
        }
        catch(e)
        {
            CPLog("Error");
            //CPLog(e);
            return [self connection:aConnection didFailWithError: e];
        }
 
        // do stuff with result
        //CPLog([result description]);
        [libraryTable setModel:result];
        
        libraryTableModel = result;
        if(artistTableViewEnabled)
            [self changeView:"Artists"];
            
        flashURL = "Resources/itunesartV5.swf?action=CoverBrowser&DTXml=/flash.html%3Faction=flashsearch%26id=qojd4iqi%26s1=" + escape(albumQuery) + "%26Type=Album%26CoverBrowse=true%26size=small%26ftype=any%26limit=50%26offset=0%26foo=bar.xml";
        if(flashEnabled)
            [self changeView:"Coverflow"];
        playlistConnection = nil;
    }

    
    //CPLog("Nope");
}
 
- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    CPLog("error is: " + anError + "yaaaaaaHHH!!!!!");
    if(anError == 0)
    {
        [sessionEndedErrorWindow runModal];
    }
    [self connectionDidFinishLoading:aConnection];
}
 
- (void)connectionDidFinishLoading:(CPURLConnection)aConnection
{
    if (connection == aConnection)
    {
        connection = nil;
    }
    if (playlistConnection == aConnection)
    {
        playlistConnection = nil;
    }
    if (searchConnection == aConnection)
    {
        searchConnection = nil;
    }
}

-(void)alertDidEnd:(id)theAlert returnCode:(int)retunrCode
{
    //show re login panel
}
    

-(void)collectionViewDidChangeSelection:(CPCollectionView)collectionView
{
    if (collectionView == playlistCollectionView)
    {
        var listIndex = [[playlistCollectionView selectionIndexes] firstIndex],
            key = [playlistCollectionView content][listIndex];
            
        playlistName = [playlists allKeys][listIndex];
        var url = [playlists objectForKey:key];
        CPLog(url);
        
        if(url == "all")
        {
            [self setAllMusicView];
        }
        
        playlistConnection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:url] delegate:self startImmediately:NO];
        [playlistConnection start];
    }
}

- (void)addPlaylist:(CPString)url withName:(CPString)aString
{
    [playlists setObject:url forKey:aString];
    
    [playlistCollectionView setContent: [[playlists allKeys] copy]];
    //[playlistCollectionView setSelectionIndexes: [CPIndexSet indexSetWithIndex: [[playlists allKeys] indexOfObject: aString]]];
}

-(void)setSong:(CPNotification)aNotification
{
    CPLog("I have recived the song");
    //if([theSoundManager isLoaded])
	//{
        var aSong = [[aNotification userInfo] objectForKey:"song"];
        //[theSoundManager stopSound];
        //[theSoundManager playSound:aSong["url"]];
        //[theSoundManager setVolume:75];
        //[QT stop];
        [QT setMovieURL:aSong["url"]];
        [QT setVolume:75];
        isSongLoaded = YES;
        isPaused = NO;
        nextTrack = 0;
        [[[[[theWindow toolbar] items] objectAtIndex:5] view] setSong:aSong];
    //}
}

-(void)setCoverflowSong:(Object)theSong
{
    CPLog("I have recived the song");
    if([theSoundManager isLoaded])
	{
        var aSong = theSong;
        //[theSoundManager stopSound];
        //[theSoundManager playSound:aSong["url"]];
        //[theSoundManager setVolume:75];
        [QT stop];
        [QT setMovieURL:aSong["url"]];
        [QT setVolume:75];
        isSongLoaded = YES;
        isPaused = NO;
        nextTrack = 0;
        [[[[[theWindow toolbar] items] objectAtIndex:5] view] setSong:aSong];
    }
}


-(void)search:(id)sender
{
    CPLog("search is " + sender);
    //ar searchValue = [[[[[[[[self window] toolbar] items] objectAtIndex:8] view] subviews] objectAtIndex:0] stringValue];
    var url = "/index.php?username=Guest&password=&action=render&render=Search.php&search=" + [sender stringValue];
    searchConnection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:url] delegate:self startImmediately:NO];
    [searchConnection start];
    searchQuery = [sender stringValue];
}

-(void)playPauseSong
{
    CPLog("here" + name);
	//if([theSoundManager isLoaded])
	//{
		if(isSongLoaded)
		{
			if(isPaused)
			{
				//[theSoundManager resumeSound];
				[QT resume];
				isPaused = NO;
				//[self setIcon:"pause"];
			}
			else
			{
				//[theSoundManager pauseSound];
				[QT pause];
				isPaused = YES;
				//[self setIcon:"play"];
			}
		}
		else
		{
			//get the first item in the song table
		}
	//}
}

-(void)setVolume:(int)vol
{
    //[theSoundManager setVolume:vol];
    [QT setVolume:vol];
}

-(void)setTime:(CPTimer)aTimer
{
    var time = [QT currentTime];
	CPLog("time: " + time);
    [[[[[theWindow toolbar] items] objectAtIndex:5] view] setTime:time];
    [[[[[theWindow toolbar] items] objectAtIndex:5] view] setNeedsDisplay:YES];
}

-(void)changePos:(CPNotification)aNotification{
    var info = [aNotification userInfo];
	var aux = [info objectForKey:"pos"];
	CPLog("aux: " + aux);
    //[theSoundManager setSoundPosition:aux];
    [QT setCurrentTime:aux];
}

-(void)songDidFinish:(CPNotification)aNote
{
	CPLog("song finished!");
	[self nextTrack];
}

-(void)nextTrack{
	nextTrack++;
	var nextSong = [libraryTable objectAtIndex:([libraryTable getSelectedItem]+nextTrack)];
	
	if(nextSong)
	{
	   //[theSoundManager stopSound];
	   //[theSoundManager playSound:nextSong["url"]];
        //[theSoundManager setVolume:75];	
        [QT stop];
        [QT setMovieURL:nextSong["url"]];
        [QT setVolume:75];
        [[[[[theWindow toolbar] items] objectAtIndex:5] view] setSong:nextSong];
        return;
    }

}

-(void)previousTrack{
	if(([libraryTable getSelectedItem]+(nextTrack-1)) >= 0)
	{
        nextTrack--;
        var nextSong = [libraryTable objectAtIndex:([libraryTable getSelectedItem]+nextTrack)];
        //[theSoundManager stopSound];
        //[theSoundManager playSound:nextSong["url"]];
        //[theSoundManager setVolume:75];	
        [QT stop];
        [QT setMovieURL:nextSong["url"]];
        [QT setVolume:75];
        [[[[[theWindow toolbar] items] objectAtIndex:5] view] setSong:nextSong];
    }
}

-(void)setIcon:(CPString)aString
{
	var icon;
	if([aString isEqualTo:"Play"])
	{
		icon = [[CPImage alloc] initWithContentsOfFile:"Resources/PlayLeopardEnabled.tiff?user=Guest&pass="];
	}
	else
	{
		icon = [[CPImage alloc] initWithContentsOfFile:"Resources/PauseLeopardEnabled.tiff?user=Guest&pass="];
	}
	//get toolbar instance
	//CPLog([[self window] toolbar]);
	[[[[theWindow toolbar] items] objectAtIndex:1] setIcon:icon];
}

-(void)changeView:(id)v
{
    var view;
    if([v isKindOfClass:[CPNotification class]])
    {
        var info = [v userInfo];
        view = [info objectForKey:"View"];
    }
    else
        view = v;
        
	CPLog("aux: " + view);
	if([view isEqualToString:"List"])
	{
	   //[[[[[theWindow toolbar] items] objectAtIndex:7] view] setSegmentWithName:"List"];
	   flashEnabled = NO;
	   [artistTableView removeFromSuperview];
	   [flashView removeFromSuperview];
	   [libraryTable setFrame:CGRectMake(200, 0, CGRectGetWidth([[theWindow contentView] bounds]) - 200, CGRectGetHeight([[theWindow contentView] bounds])+59)];
    }
	if([view isEqualToString:"Artists"])
	{
	   flashEnabled = NO;
	   [flashView removeFromSuperview];
	   [libraryTable setFrame:CGRectMake(200, 300, CGRectGetWidth([[theWindow contentView] bounds]) - 200, (CGRectGetHeight([[theWindow contentView] bounds])-241))];//300
	   //artistView = [[DTArtistTable alloc] initWithFrame:CGRectMake(200, 300, CGRectGetWidth([[theWindow contentView] bounds]) - 200, (CGRectGetHeight([[theWindow contentView] bounds])-241)) model:nil];
	   if(libraryTableModel != nil)
	   {
            //[[[[[theWindow toolbar] items] objectAtIndex:7] view] setSegmentWithName:"Artists"];
            artistViewEnabled = YES;
            [artistTableView setModel:libraryTableModel];
	       [[theWindow contentView] addSubview:artistTableView];
	   }
	   if(playlistName == "___all___")
	   {
	       [[theWindow contentView] addSubview:artistTableView];
	   }    
	   //CPLog(artistView);
	   //[[theWindow contentView] addSubview:artistView];
	   
	}
	if([view isEqualToString:"Coverflow"])
	{
	   [artistTableView removeFromSuperview];
	   [libraryTable setFrame:CGRectMake(200, 300, CGRectGetWidth([[theWindow contentView] bounds]) - 200, (CGRectGetHeight([[theWindow contentView] bounds])-241))];//300
	   if(flashURL != nil)
	   {
	       //[[[[[theWindow toolbar] items] objectAtIndex:7] view] setSegmentWithName:"Coverflow"];
	       flashEnabled = YES;
	       [flashView setFlashMovie:[CPFlashMovie flashMovieWithFile:flashURL]];
	       [[theWindow contentView] addSubview:flashView];
	   }
    }
}

- (void)changeArtist:(CPNotification)aNotification
{
    artistQuery = [[aNotification userInfo] objectForKey:"Artist"];
    var url = "/index.php?username=Guest&password=&action=render&render=AllArtistTrax.php&Artist=" + escape(artistQuery);
    artistConnection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:url] delegate:self startImmediately:NO];
    [artistConnection start];
}

- (void)changeAlbum:(CPNotification)aNotification
{
    artistQuery = [[aNotification userInfo] objectForKey:"Artist"];
    albumQuery = [[aNotification userInfo] objectForKey:"Album"];
    var url = "/index.php?username=Guest&password=&action=render&render=ArtistTrax.php&Artist=" + escape(artistQuery) + "&Album=" + escape(albumQuery);
    albumConnection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:url] delegate:self startImmediately:NO];
    [albumConnection start];
}


@end

function coverflowClicked(name, artist, album, url)
{
    CPLog("i've been called");
    CPLog( name + artist + album + url);
    var song = new Array();
    song["url"] = url;
    song["name"] = name;
    song["Artist"] = artist;
    song["Album"] = album;
    song["Time"] = "12345678987";
    
    //[CPApp sendAction:@selector(setSong:) to: theAppControl from: song];
    [theAppControl setCoverflowSong:song];
}
    

@implementation volumeView : CPView
{
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    
    var slider = [[CPSlider alloc] initWithFrame: CGRectMake(38, CGRectGetHeight(aFrame)/2.0 - 8, CGRectGetWidth(aFrame) - 105, 16)];//105

    [slider setMinValue: 0.0];
    [slider setMaxValue: 100.0];
    [slider setTarget: self];
    [slider setAction: @selector(sliderChangedValue:)];
    
    [self addSubview: slider];

    [slider setValue: 75.0];
                                                             
    var volImage = [[CPImageView alloc] initWithFrame: CGRectMake(10, CGRectGetHeight(aFrame)/2.0-8, 40, 17)];
    [volImage setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/VolumeMeter1.tif" size:CPSizeMake(18, 17)]];
    [self addSubview: volImage];

    volImage = [[CPImageView alloc] initWithFrame: CGRectMake(CGRectGetWidth(aFrame) - 75, CGRectGetHeight(aFrame)/2.0 - 8, 40, 17)];
    [volImage setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/VolumeMeter3.tif" size:CPSizeMake(18, 17)]];
    [self addSubview: volImage];    
    return self;
}

- (void)sliderChangedValue:(id)sender
{
    //[CPApp sendAction:@selector(adjustImageSize:) to: nil from: sender];
    [theAppControl setVolume:[sender value]];
}

@end

@implementation SearchView : CPView
{
}

- (id)initWithFrame:(CGRect)aFrame target:(id)target
{
    self = [super initWithFrame:aFrame];
    
    var searchField = [[CPTextField alloc] initWithFrame:CGRectMake(38, CGRectGetHeight(aFrame)/2.0-12, CGRectGetWidth(aFrame)-50, 25)];
    //[searchField setAlignment:CPCenterTextAlignment];
    
    
    [self addSubview: searchField];
    [searchField setStringValue:"Search"];
    [searchField setEditable:YES];
    [searchField setBezeled:YES];
    [searchField setBordered:YES];
    [searchField setSelectable:YES];
    [searchField setBezelStyle:CPTextFieldSquareBezel];
    [searchField setTarget:target];
    [searchField setAction:@selector(search:)];
    return self;
}


@end

@implementation PlayListCell : CPView
{
    CPTextField     label;
    CPImageView     playlistIcon;
    CPView          highlightView;
}

- (void)setRepresentedObject:(JSObject)anObject
{
    var all = 0;
    if(!label)
    {
        if([anObject isEqualToString:"___all___"]) all = 1;
        
        label = [[CPTextField alloc] initWithFrame:CGRectMake(CGRectGetWidth([self bounds])/2.0+8, CGRectGetHeight([self bounds])+8, 100, 25)];
        
        [label setFont: [CPFont systemFontOfSize: 12.0]];
        [label setTextColor: [CPColor blackColor]];
        
        [self addSubview: label];
        
        playlistIcon = [[CPImageView alloc] initWithFrame: CGRectMake(10, CGRectGetHeight([self bounds])/2.0+8.0, 16, 16)];
        if(all == 1)
        {
            var icon = "Resources/music.png";
        }
        else
        {
            var icon = "Resources/playlist.png";
        }
            
        [playlistIcon setImage:[[CPImage alloc] initWithContentsOfFile:icon size:CPSizeMake(16, 16)]];
        [self addSubview: playlistIcon];
        
    }
    
    if(all == 1)
    {
        var string = "All Music";
    }
    else
    {
        var string = anObject;
    }

    
    [label setStringValue: string];
    [label sizeToFit];

    [label setFrameOrigin: CGPointMake(25,CGRectGetHeight([label bounds])/4.0)];
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
