//
//  SMSoundManager.j
//  SoundManager
//
//  Created by Ross Boucher on 10/3/08.
//  Copyright 280 North 2008. All rights reserved.
//

@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
//@import <AppKit/Platform/Platform.h>
//@import <AppKit/Platform/DOM/CPDOMDisplayServer.h>

@implementation CPQuicktimeController : CPObject
{
    CPQuicktimeView _parent;
    var quicktimeObject;    
    
    CPString _id;
    
    BOOL _isPaused;
    int _rate;
}

- (id)initWithContentsOfFile:(CPString)aFile identifier:(CPString)aID//plays in background
{
    return [self initWithFrame:CGRect(0,0,1,1) contentsOfFile:aFile parent:nil];
}

- (id)initWithFrame:(CGRect)aFrame contentsOfFile:(CPString)aFile identifier:(CPString)aID parent:(CPQuicktimeView)aParent;
    self = [super init];
    
    var haveqt = NO;
    
    if (navigator.plugins) 
    {
        for (i=0; i < navigator.plugins.length; i++ ) 
        {
            if (navigator.plugins[i].name.indexOf("QuickTime") >= 0)
            { 
                haveqt = YES; 
            }
        }
    }
 
    if ((navigator.appVersion.indexOf("Mac") > 0) && (navigator.appName.substring(0,9) == "Microsoft") && (parseInt(navigator.appVersion) < 5) )
    { 
        haveqt = true; 
    }
    
    if(!haveqt)
        return nil;
        
    _parent = nil;
    if(aParent)
        _parent = aParent;
        
    _id = aID;
    if(_id == nil || _id = "CPQuicktimeController")
    {
        if(!document.getElementById('CPQuicktimeController'))
        {
            _id = "CPQuicktimeController";
        }
        else
        {
            //throw excpetion
            return nil;
        }
    }        
        
    var qtArgs = new Array(aFile , CGRectGetWidth(aFrame), CGRectGetHeight(aFrame) '', 'EnableJavaScript', 'True', 'postdomevents', 'True', 'emb#NAME' , aID , 'obj#id' , aID, 'emb#id', aID) ;    
    
    if(_parent)
        [_parent addQuickTimeController:_QTGenerate("QT_WriteOBJECT", false, qtArgs);];
    else
        document.writeln(_QTGenerate("QT_WriteOBJECT", false, qtArgs));
        
    quicktimeObject = document.getElementById(_id); 
        
    if ( document.addEventListener )
    {
        quicktimeObject.addEventListener("qt_begin", function(){ [self notificationBegin]; }, false);
        quicktimeObject.addEventListener("qt_loadedmetadata", function(){ [self notificationLoadedMetaData]; }, false);
        quicktimeObject.addEventListener("qt_loadedfirstframe", function(){ [self notificationLoadedFirstFrame]; }, false);
        quicktimeObject.addEventListener("qt_canplay", function(){ [self notificationCanPlay]; }, false);
        quicktimeObject.addEventListener("qt_canplaythrough", function(){ [self notificationCanPlayThrough]; }, false);
        quicktimeObject.addEventListener("qt_durationchange", function(){ [self notificationDurationChange]; }, false);
        quicktimeObject.addEventListener("qt_load", function(){ [self notificationLoad]; }, false);
        quicktimeObject.addEventListener("qt_ended", function(){ [self notificationEnded]; }, false);
        quicktimeObject.addEventListener("qt_error", function(){ [self notificationError]; }, false);
        quicktimeObject.addEventListener("qt_pause", function(){ [self notificationPause]; }, false);
        quicktimeObject.addEventListener("qt_play", function(){ [self notificationPlay]; }, false);
        quicktimeObject.addEventListener("qt_progress", function(){ [self notificationProgress]; }, false);
        quicktimeObject.addEventListener("qt_waiting", function(){ [self notificationWating]; }, false);
        quicktimeObject.addEventListener("qt_stalled", function(){ [self notificationStalled]; }, false);
        quicktimeObject.addEventListener("qt_timechanged", function(){ [self notificationTimeChanged]; }, false);
        quicktimeObject.addEventListener("qt_volumechange", function(){ [self notificationVolumeChanged]; }, false);
    }
    else
    {
        // IE
        quicktimeObject.attachEvent('on' + "qt_begin", function(){ [self notificationBegin]; });
        quicktimeObject.attachEvent('on' + "qt_loadedmetadata", function(){ [self notificationLoadedMetaData]; });
        quicktimeObject.attachEvent('on' + "qt_loadedfirstframe", function(){ [self notificationLoadedFirstFrame]; });
        quicktimeObject.attachEvent('on' + "qt_canplay", function(){ [self notificationCanPlay]; }, false);
        quicktimeObject.attachEvent('on' + "qt_canplaythrough", function(){ [self notificationCanPlayThrough]; });
        quicktimeObject.attachEvent('on' + "qt_durationchange", function(){ [self notificationDurationChange]; });
        quicktimeObject.attachEvent('on' + "qt_load", function(){ [self notificationLoad]; });
        quicktimeObject.attachEvent('on' + "qt_ended", function(){ [self notificationEnded]; });
        quicktimeObject.attachEvent('on' + "qt_error", function(){ [self notificationError]; });
        quicktimeObject.attachEvent('on' + "qt_pause", function(){ [self notificationPause]; });
        quicktimeObject.attachEvent('on' + "qt_play", function(){ [self notificationPlay]; });
        quicktimeObject.attachEvent('on' + "qt_progress", function(){ [self notificationProgress]; });
        quicktimeObject.attachEvent('on' + "qt_waiting", function(){ [self notificationWating]; });
        quicktimeObject.attachEvent('on' + "qt_stalled", function(){ [self notificationStalled]; });
        quicktimeObject.attachEvent('on' + "qt_timechanged", function(){ [self notificationTimeChanged]; });
        quicktimeObject.attachEvent('on' + "qt_volumechange", function(){ [self notificationVolumeChanged]; });
    }
    
    return self;
}

//Movie Commands

/*!
    Plays the quicktime object at the default rate, starting from the movie’s current time.
*/
- (BOOL)isPlaying
{
    return (quicktimeObject.GetRate() > 0 );
}

- (void)play
{
    quicktimeObject.Play();
    _isPlaying = YES;
}

/*!
    Pauses the quicktime object.
*/
- (void)pause
{
    if(!_isPaused && quicktimeObject.GetRate() > 0)
    {
        _isPaused = YES;
        _rate = quicktimeObject.GetRate();
        quicktimeObject.SetRate(0.0);
    }
}

/*!
    Resumes the quicktime object.
*/
- (void)resume
{
    if(_isPaused && quicktimeObject.GetRate() == 0)
    {
        _isPaused = NO;
        _rate = nil;
        quicktimeObject.SetRate(_rate);
    }
}

/*!
    Stops the quicktime object.
*/
- (void)stop
{
    quicktimeObject.Stop();
}

/*!
    Sets the current time to the movie’s start time and pauses the movie.
*/
-(void)rewind
{
    quicktimeObject.Rewind();
}

/*
    Steps the movie forward or backward the specified number of frames from the point at which the command is received. If the movie’s rate is non-zero, it is paused.
    @param the number of steps
*/
-(void)setStep:(int)aCount
{
    quicktimeObject.Step(aCount);
}

/*
    Displays a QuickTime VR movie’s default node, using the default pan angle, tilt angle, and field of view as set by the movie’s author. Only works if there is a parent CPQuicktimeView.
*/
-(void)showDefualtView
{
    if(_parent)
        quicktimeObject.ShowDefaultView();
}

/*
    Returns to the previous node in a QuickTime VR movie (equivalent to clicking the Back button on the VR movie controller). Only works if there is a parent CPQuicktimeView.
*/
-(void)goPreiousNode
{
    if(_parent)
        quicktimeObject.GoPreviousNode();
}

/*
    Takes a chapter name and sets the movie's current time to the beginning of that chapter. See also: GetChapterName and GetChapterCount in movie properties.
    @param the chapter name
*/
-(void)goToChapter:(CPString)aName
{
    quicktimeObject.GoToChapter(aName);
}

//Quicktime/Plugin Properties

/*
    Returns the version of QuickTime.
*/
-(CPString)quickTimeVersion
{
    return quicktimeObject.GetQuickTimeVersion();
}

/*
    Returns the user’s QuickTime language (set through the plug-in’s Set Language dialog).
*/
-(CPString)quickTimeLanguage
{
    return quicktimeObject.GetQuickTimeLanguage();
}

/*
    Returns the connection speed setting from the users QuickTime preferences.
*/
-(int)quickTimeConnectionSpeed
{
    return quicktimeObject.GetQuickTimeConnectionSpeed();
}

/*
    Returns YES if the user is registered for the Pro version of QuickTime; otherwise returns NO.
*/
-(BOOL)isQuicktimeRegistered
{
    return quicktimeObject.GetIsQuickTimeRegistered();
}

/*
    Returns the version of a specific QuickTime component. The component is specified using a four character string for the type, subtype, and manufacturer. For example, to check the version of Apple’s JPEG graphics importer call GetComponentVersion> 'grip','JPEG','appl').'0' is a wildcard for any field. If the component is not available, 0.0 is returned.
    @param four character string for the type
    @param four character string for the sub type
    @param four character string for the manfacturer
*/
-(CPString)componentVersionFromType:(CPString)aType subType:(CPString)aSubType manufacturer:(CPString)aManufacturer
{
    return quicktimeObject.GetComponentVersion(aType, aSubType, aManufacturer);
} 

/*
    Returns the version of the QuickTime plug-in.
*/
-(CPString)pluginVersion
    return quicktimeObject.GetPluginVersion();
}

/*
    Finds out if the movie and plug-in properies are reset when a new movie is loaded. By default, most movie and plug-in properies are reset when a new movie is loaded. For example, when a new movie loads, the default controller setting is true for a linear movie and false for a VR movie, regardless of the prior setting. If this property is set to false, the new movie inherits the settings in use with the current movie.
*/
-(BOOL)doesResetPropertiesOnReload
{
    return quicktimeObject.GetResetPropertiesOnReload();
}

/*  
    Sets whether the movie and plug-in properies are reset when a new movie is loaded. By default, most movie and plug-in properies are reset when a new movie is loaded. For example, when a new movie loads, the default controller setting is true for a linear movie and false for a VR movie, regardless of the prior setting. If this property is set to false, the new movie inherits the settings in use with the current movie.
    @param BOOL to decide if the movie and plug-in properies should be reset when a new movie is loaded.
*/             
-(void)setResetPropertiesOnReload:(BOOL)shouldResetPropertiesOnReload
{
    return quicktimeObject.SetResetPropertiesOnReload(shouldResetPropertiesOnReload);
}

//Movie Properties

/*
    returns a string with the status of the current movie. Possible states are:
    ”Waiting”—waiting for the movie data stream to begin
    ”Loading”—data stream has begun, not able to play/display the movie yet
    ”Playable”—movie is playable, although not all data has been downloaded
    ”Complete”—all data has been downloaded
    ”Error: <error number>”—the movie failed with the specified error number
    Note: Even though the method is named GetPluginStatus it gets the status of a specific movie, not the status of the plug-in as a whole. If more than one movie is embedded in a document, there can be a different status for each movie. For example, one movie could be   playable while another is still loading.
*/
-(CPString)pluginStatus
{
    return quicktimeObject.GetPluginStatus();
}

/* 
    Find out if a movie automatically starts playing as soon as it can.
*/
-(BOOL)doesAutoPlay
{
    return quicktimeObject.GetAutoPlay();
}

/*
    Sets whether a movie automatically starts playing as soon as it can. This method is roughly equivalent to setting the AUTOPLAY parameter in the <EMBED> tag, but the @HH:MM:SS:FF feature is not yet supported in JavaScript.
    @param BOOl to decide if the movie should autoplay
*/
-(void)setAutoPlay:(BOOL)shouldAutoPlay
{
    quicktimeObject.SetAutoPlay(BOOL);
}

/*
    Find out if a movie has a visible controller. Only works if there is a parent CPQuicktimeView.
*/
-(BOOL)hasVisibleController
{
    if(_parent)
        return quicktimeObject.GetControllerVisible();
    else
        return NO;
}

/* 
    Sets whether a movie has a visible controller. This method is equivalent to setting the CONTROLLER parameter in the <EMBED> tag. Only works if there is a parent CPQuicktimeView.
    @param BOOL to set whether a movie has a visible controller
*/
-(void)setHasVisibleController:(BOOL)shouldHaveVisibleController       
{
    if(parent)
        quicktimeObject.SetControllerVisible(shouldHaveVisibleController);
}

/*
    Find out the playback rate of the movie. A rate of 1 is the normal playback rate. A paused movie has a rate of 0. Fractional values are slow motion, and values greater than one are fast-forward. Negative values indicate that the movie is playing backward.
    Note: Rate goes to zero when the movie finishes playing or is stopped (by the user, for example). You can use the time: and duration: methods to determine whether the movie is stopped at the end, the beginning (time zero), or at some point in between. You may also want the call GetIsLooping to determine whether the movie will end spontaneously.
*/
-(float)rate
{
    return quicktimeObject.GetRate();
}

/* Sets the playback rate of the movie. A rate of 1 is the normal playback rate. A paused movie has a rate of 0. Fractional values are slow motion, and values greater than one are fast-forward. Negative values indicate that the movie is playing backward. Setting the rate of a paused movie to a nonzero value starts the movie playing.
    @param BOOL to Set the playback rate of the movie
*/  
-(void)setRate:(float)aRate
{
    quicktimeObject.SetRate(aRate);
}


/*
    Get the current time of a movie.
*/
-(int)currentTime
{
    quicktimeObject.GetTime();
}

/*
    Set the current time of a movie. Setting this property causes a movie to go to that time in the movie and stop.
    @param a time the movie should go to.
*/
-(void)setCurrentTime:(int)aTime
{
    quicktimeObject.SetTime(aTime);
}

/*
    Get the audio volume of the movie. A negative value mutes the movie.
*/
-(int)volume
{
    quicktimeObject.GetVolume();
}

/*
    Set the audio volume of the movie. A negative value mutes the movie. The Set method is equivalent to setting the VOLUME parameter in the <EMBED> tag.
    @param a new volume
*/
-(void)setVolume:(int)aVolume
{
    quicktimeObject.SetVolume(aVolume);
}

/* 
    Find out whether the volume is muted.
*/
-(BOOL)isMuted
{
    return quicktimeObject.GetMute();
}

/* 
    Set the audio mute of a movie while maintaining the magnitude of the volume, so turning mute off restores the volume.
    @param BOOl to decide to mute the audio
*/
-(void)setIsMuted:(BOOL)shouldMute
{
    quicktimeObject.SetMute(shouldMute);
}    

/*
    Get the name that can be used by a wired sprite when targeting an external movie.
*/
-(CPString)name
{
    return quicktimeObject.GetMovieName();
}

/* 
    Set a name that can be used by a wired sprite when targeting an external movie. The Set method is equivalent to setting the MOVIENAME parameter in the <EMBED> tag.
    @param a new movie name
*/
-(void)setName:(CPString)name
{
    quicktimeObject.SetMovieName(name);
}

/*
    Get the ID that can be used by a wired sprite when targeting an external movie. Note: MovieID is not the same as the NAME parameter in the <EMBED> tag or the id parameter in the <OBJECT> tag. MovieID is used for wired sprite addressing, not JavaScript addressing.
*/
-(int)movieID
{
    return quicktimeObject.GetMovieID();
}

/*
    Set an ID that can be used by a wired sprite when targeting an external movie. The Set method is equivalent to setting the MOVIEID parameter in the <EMBED> tag. Note: MovieID is not the same as the NAME parameter in the <EMBED> tag or the id parameter in the <OBJECT> tag. MovieID is used for wired sprite addressing, not JavaScript addressing.
    @param a new movie id integer
*/
-(void)setMovieID:(int)aID
{
    quicktimeObject.SetMovieID(aID);
}

/*
    Returns the number of chapters in the movie.
*/
-(void)chapterCount
{
    return quicktimeObject.GetChapterCount();
}

/*
    Takes a chapter number and returns the chapter name.
    @param a chapter number
*/
-(CPString)chapterNameFromNumber:(int)aChapter
{
    return quicktimeObject.GetChapterName(aChapter);
}

/*
    Get the time at which a movie begins to play and the time at which it stops or loops when playing in reverse. Initially, the start time of a movie is set to 0 unless specified in the STARTTIME parameter in the <EMBED> tag.          
*/
-(int)startTime
{
    return quicktimeObject.GetStartTime();
}

/*
    Set the time at which a movie begins to play and the time at which it stops or loops when playing in reverse. Initially, the start time of a movie is set to 0 unless specified in the STARTTIME parameter in the <EMBED> tag. The start time cannot be set to a time greater than the end time. The Set method is equivalent to setting the STARTTIME parameter in the <EMBED> tag.  
    @param a new start time
*/
-(void)setStartTime:(int)aTime
{
    quicktimeObject.SetStartTime(aTime);
}

/*
    Get the time at which a movie stops playing or loops. The end time of a movie is initially set to its duration, unless specified in the ENDTIME parameter in the <EMBED> tag.    
*/
-(int)endTime
{
    return quicktimeObject.GetEndTime();
}

/*
    Set and set the time at which a movie stops playing or loops. The end time of a movie is initially set to its duration, unless specified in the ENDTIME parameter in the <EMBED> tag. The end time cannot be set to a time greater than the movie’s duration. The Set method is equivalent to setting the ENDTIME parameter in the <EMBED> tag.
    @param a new end time
*/ 
-(void)setEndTime:(int)aTime
{
    return quicktimeObject.SetEndTime(aTime);
}

/*
    Get the color used to fill any space allotted to the plug-in by the <EMBED> tag and not covered by the movie. Regardless of the syntax used to specify the color, GetBgColor() always returns the color as a number—for example, if the background color is set to Navy, bgColor: returns #000080. Only works if there is a parent CPQuicktimeView.
*/
-(CPString)bgColor
{
    if(_parent)
        return quicktimeObject.GetBgColor();
    else
        return nil;
}    

/*
    Find out whether a movie loops when it reaches its end. A movie can loop either by restarting when it reaches the end or by playing backward when it reaches the end, then restarting when it reaches the beginning, depending on the LoopIsPalindrome value.
*/
-(BOOL)isLooping
{
    quicktimeObject.GetIsLooping();
}

/*
    Set whether a movie loops when it reaches its end. A movie can loop either by restarting when it reaches the end or by playing backward when it reaches the end, then restarting when it reaches the beginning, depending on the LoopIsPalindrome value. Using the SetIsLooping method is equivalent to setting the LOOP parameter to true or false in the <EMBED> tag.
    @param BOOL to set looping
*/
-(void)setIsLooping:(BOOL)doesLoop
{
    quicktimeObject.SetIsLooping(doesLoop);
}

/*
    Find out whether a looping movie reverses direction when it loops, alternately playing backward and forward. The loop property must be true for this to have any effect.
*/
-(BOOL)loopsIsPalindrome
{
    return quicktimeObject.GetLoopIsPalindrome();
}

/* 
    Set whether a looping movie reverses direction when it loops, alternately playing backward and forward. The loop property must be true for this to have any effect. Setting both IsLooping and LoopIsPalindrome to true is equivalent to setting the LOOP parameter to Palindrome in the <EMBED> tag.
    @param BOOL to set whether a looping movie reverses direction when it loops
*/
-(void)setLoopsIsPalindrome:(BOOL)shouldLoopPalindrome
{
    quicktimeObject.SetLoopIsPalindrome(shouldLoopPalindrome);
}

/* 
    Find out whether QuickTime should play every frame in a movie even if it gets behind (playing in slow motion rather than dropping frames). The sound is muted when playAll is set true.
*/
-(BOOL)doesPlayEveryFrame
{
    return quicktimeObject.GetPlayEveryFrame();
}

/*
    Set whether QuickTime should play every frame in a movie even if it gets behind (playing in slow motion rather than dropping frames). The sound is muted when playAll is set true. The Set method is equivalent to setting the PLAYEVERYFRAME parameter in the <EMBED> tag.
    @param BOOL to determine whetjer the movie should play every frame
*/
-(void)setPlayEveryFrame:(BOOL)shouldPlayEveryFrame
{
    quicktimeObject.SetPlayEveryFrame(shouldPlayEveryFrame);
}

/*
    Get the URL that is invoked by a mouse click in a movie’s display area. The URL can specify a web page, a QuickTime movie, a live streaming session, or be a JavaScript function name.    
*/
-(CPString)movieHREF
{
    return quicktimeObject.GetHREF();
}

/*
    Set the URL that is invoked by a mouse click in a movie’s display area. The URL can specify a web page, a QuickTime movie, a live streaming session, or be a JavaScript function name. The Set method is equivalent to setting the HREF parameter in the <EMBED> tag.
    @param a new url
*/
-(void)setMovieHREF:(CPString)aURL
{
    quicktimeObject.SetHREF(aURL);
}

/*
    Get the target for a movie’s HREF parameter. The target can be an existing frame or browser window, a new browser window, myself (the QuickTime plug-in), or quicktimeplayer.     
*/
-(CPString)movieTarget
{
    return quicktimeObject.GetTarget();
}

/*
    Set the target for a movie’s HREF parameter. The target can be an existing frame or browser window, a new browser window, myself (the QuickTime plug-in), or quicktimeplayer. The Set method is equivalent to setting the TARGET parameter in the <EMBED> tag.           
    @param a new target
*/
-(void)setMovieTarget:(CPString)aTarget
{
    quicktimeObject.SetTarget(aTarget);
}

/*
    Get the URL and target for a specified item in a sequence. The URL of the first item in the sequence is invoked when the currently selected movie finishes. If the URL specifies a QuickTime movie and the special target myself, the next specified URL in the sequence is invoked when that movie finishes, and so on.
    @param an Index for a next url
*/
-(CPString)nextURLForIndex:(int)aIndex
{
    return quicktimeObject.GetQTNEXTUrl(aIndex);
}         
         
/*
    Set the URL and target for a specified item in a sequence. The URL of the first item in the sequence is invoked when the currently selected movie finishes. If the URL specifies a QuickTime movie and the special target myself, the next specified URL in the sequence is invoked when that movie finishes, and so on. The Set method is equivalent to setting the QTNEXTn parameter in the <EMBED> tag.
    @param an Index for a next URL
    @param a url for the next url
*/
-(void)setNextUrlForIndex:(int)aIndex url:(CPString)aURL
{
    quicktimeObject.SetQTNEXTUrl(aIndex, aURL);
}

/*
   Returns a movie’s full URL.
*/
-(CPString)movieURL
{
    return quicktimeObject.GetURL();
}

/*
    Replaces a movie with another movie specified by the URL.
    @param a new URL
*/
-(void)setMovieURL:(CPString)aURL
{
    quicktimeObject.SetURL(aURL);
}

/*
    Find out whether kiosk mode is currently set. In kiosk mode, the QuickTime plug-in does not allow the viewer to save a movie to disk. Only works if there is a parent CPQuicktimeView.
*/
-(BOOL)isKioskMode
{
    if(_parent)
        return quicktimeObject.GetKioskMode();
}  

/* 
    Set whether kiosk mode is currently set. In kiosk mode, the QuickTime plug-in does not allow the viewer to save a movie to disk. Setting kioskMode to true is equivalent to setting the KIOSKMODE parameter in the <EMBED> tag. Only works if there is a parent CPQuicktimeView.
    @param BOOL to enable Kiosk Mode
*/
-(void)setKioskMode:(BOOL)shouldEnableKiosk
{
    quicktimeObject.SetKioskMode(shouldEnableKiosk);
}

/*
    Returns the length of the movie (in the movie’s time scale units).
*/
-(int)duration
{
    return quicktimeObject.GetDuration();
}

/*
    Returns the amount of the movie that has been downloaded (in the movie’s time scale units).
*/
-(int)maxTimeLoaded
{
    return quicktimeObject.GetMaxTimeLoaded();
}

/*
    Returns the time scale of the movie in units per second. For example, if GetTimeScale() returns 30, each movie time scale unit represents 1/30 of a second.
*/
-(int)timeScale
{
    return quicktimeObject.GetTimeScale();
}

/*
    Returns the size of the movie in bytes.
*/
-(int)movieSize
{
    return quicktimeObject.GetMovieSize();
}

/*
    Returns the number of bytes of the movie that have been downloaded.
*/
-(int)maxBytesLoaded
{
    return quicktimeObject.GetMaxBytesLoaded();
}

/*
    Returns the total number of tracks in the movie.
*/
-(int)trackCount
{
    return quicktimeObject.GetTrackCount();
}

/*
    Get a movie’s transformation matrix.
    @param class of which you want the matrix to be of, either CPString or CPArray
*/                             
-(id)matrixOfClass:(Class)aClass
{
    var matrixString = quicktimeObject.GetMatrix();
    if(aClass == [CPArray class])
    {
        var matrixArray = matrixString.split(/\n/g);
        var matrixMultiDemensionalArray;
        for(i=0; i<matrixArray.count; i++)
        {
            matrixMultiDemensionalArray[i] = matrixArray[i].split(", ");
        }
        return matrixMultiDemensionalArray;
    }
    return matrixString; 
}

/*
    Set a movie’s transformation matrix.
*/
-(void)setMatrix:(id)aMatrix
{
    var matrixString;
    if([aMatrix class] == [CPArray class])
    {
        for(i=0; i<[aMatrix count]; i++)
        {
            for(j=0; j<[[aMatrix objectAtIndex:i] count]; j++)
            {
                matrixString += [[aMatrix objectAtIndex:i] objectATIndex:j];
                if(j != [[aMatrix objectAtIndex:i] count]-1) matrixString += ", ";
            }
            if(i != [aMatrix count]-1) matrixString += ", "; 
        }
    }
    quicktimeObject.SetMatrix(matrixString);
}

/*
    Get the movie’s current language. Supported language names: Albanian, Arabic, Belorussian
Bulgarian
Croatian
Czech
Danish
Dutch
English
Estonian
Faeroese
Farsi
Finnish
Flemish
French
German
Greek
Hebrew
Hindi
Hungarian
Icelandic
Irish
Italian
Japanese
Korean
Latvian
Lithuanian
Maltese
Norwegian
Polish
Portuguese
Romanian
Russian
Saamisk
Serbian
Simplified Chinese
Slovak
Slovenian
Spanish
Swedish
Thai
Traditional Chinese
Turkish
Ukrainian
Urdu
Yiddish
*/
-(CPString)language
{
    return quicktimeObject.GetLanguage();
}

/*
    Set the movie’s current language. Setting the language causes any tracks associated with that language to be enabled and tracks associated with other languages to be disabled. If no tracks are associated with the specified language, the movie’s language is not changed.

Supported language names:

Albanian
Arabic
Belorussian
Bulgarian
Croatian
Czech
Danish
Dutch
English
Estonian
Faeroese
Farsi
Finnish
Flemish
French
German
Greek
Hebrew
Hindi
Hungarian
Icelandic
Irish
Italian
Japanese
Korean
Latvian
Lithuanian
Maltese
Norwegian
Polish
Portuguese
Romanian
Russian
Saamisk
Serbian
Simplified Chinese
Slovak
Slovenian
Spanish
Swedish
Thai
Traditional Chinese
Turkish
Ukrainian
Urdu
Yiddish
    @param a new language
*/
-(void)setLanguage:(CPString)aLanguage
{
    quicktimeObject.SetLanguage(aLanguage);
}

/*
    Returns the movie’s MIME type.
*/
-(CPString)MIMEType
{
    return quicktimeObject.GetMIMEType();
}

/*
    Returns the movie user data text with the specified tag. The tag is specified with a four-character string; for example, '©cpy' returns a movie’s copyright string. The following table contains a list of user data tags.
    '©nam', Movie’s name
    '©cpy', Copyright statement
    '©day', Date the movie content was created
    '©dir', Name of movie’s director
    '©ed1' to '© ed9', Edit dates and descriptions
    '©fmt', Indication of movie format (computer-generated, digitized, and so on)
    '©inf', Information about the movie
    '©prd', Name of movie’s producer
    '©prf', Names of performers
    '©req', Special hardware and software requirements
    '©src', Credits for those who provided movie source content
    '©wrt', Name of movie’s writer
    @param type of user data
*/
-(CPString)userDataOfType:(CPString)aType
{
    return quicktimeObject.GetUserData(aType);
}

/*
    Returns true if the movie is a QuickTime VR movie, false otherwise. Only works if there is a parent CPQuicktimeView.
*/
-(BOOL)isVRMovie
{
    if(_parent)
        return quicktimeObject.GetIsVRMovie();
    else
        return NO;
}

//VR Movie Properties

/*
    Get the URL associated with a specified VR movie hot spot. Only works if there is a parent CPQuicktimeView.
    @param A Hotpot ID
*/
-(CPString)hotpotURLForID:(int)aID
{
    if(_parent)
        return quicktimeObject.GetHotspotUrl(aID); 
    else
        return nil;
}

/*
    Set the URL associated with a specified VR movie hot spot. The Set method is equivalent to setting the HOTSPOTn parameter in the <EMBED> tag. Only works if there is a parent CPQuicktimeView.
    @param A Hotspot ID
    @param A Hotspot URL
*/
-(void)setHotspotForID:(int)aID url:(CPString)aURL
{
    if(_parent)
        quicktimeObject.SetHotspotUrl(aID, aURL);
}

/*
    Get the target for a specified VR movie hot spot. Only works if there is a parent CPQuicktimeView.
    @param A Hotspot ID
*/
-(CPString)hotspotTargetForID:(int)aID
{
    if(_parent)
        return quicktimeObject.GetHotspotTarget(aID);
    else
        return nil;
}

/*
    Set the target for a specified VR movie hot spot. The Set method is equivalent to setting the TARGETn parameter in the <EMBED> tag. Only works if there is a parent CPQuicktimeView.
    @param A Hotspot ID
*/
-(void)setHotspotTagetForID:(int)aID target:(CPString)aTarget
{
    if(_parent)
        quicktimeObject.SetHotspotTarget(aID, aTarget);
}

/*
    Get QuickTime VR movie’s pan angle (in degrees). Only works if there is a parent CPQuicktimeView.
*/
-(float)panAngle
{
    if(_parent)
        return quicktimeObject.GetTiltAngle();
    else
        return nil;
}

/*
    Set the QuickTime VR movie’s pan angle (in degrees). The Set method is equivalent to setting the PAN parameter in the <EMBED> tag. Only works if there is a parent CPQuicktimeView.
    @param a new pan angle
*/
-(void)setPanAngle:(float)aAngle
{
    if(_parent)
        quicktimeObject.SetPanAngle(aAngle);
}

/*
    Get the QuickTime VR movie’s tilt angle (in degrees). Only works if there is a parent CPQuicktimeView.
*/
-(float)tiltAngle
{
    if(_parent)
        return quicktimeObject.GetTiltAngle();
    else
        return nil;
}

/*
    Set the QuickTime VR movie’s tilt angle (in degrees).The Set method is equivalent to setting the TILT parameter in the <EMBED> tag. Only works if there is a parent CPQuicktimeView.
    @param a new tilt angle
*/
-(void)setTiltAngle:(float)aAngle
{
    if(_parent)
        quicktimeObject.SetTiltAngle(aAngle);
}

/*
    Get and set the QuickTime VR movie’s field of view (in degrees). Only works if there is a parent CPQuicktimeView.
*/
-(float)fieldOfView
{
    if(_parent)
        return quicktimeObject.GetFieldOfView();
    else
        return nil;
}

/*
    Set the QuickTime VR movie’s field of view (in degrees). Setting a narrower field of view causes the VR to “zoom in.” Setting a wider field of view causes the VR to “zoom out.” The Set method is equivalent to setting the FOV parameter in the <EMBED> tag.
    Only works if there is a parent CPQuicktimeView.
    @param a new field of view
*/    
-(void)setFieldOfView:(float)aView
{
    if(_parent)
        quicktimeObject.SetFieldOfView(aView);
}

/*
    Returns the number of nodes in a QuickTime VR movie. Only works if there is a parent CPQuicktimeView.
*/
-(int)nodeCount
{
    if(_parent)
        return quicktimeObject.GetNodeCount();
    else
        return nil;
}

/*
    Returns the ID of the current node in a QuickTime VR movie. Only works if there is a parent CPQuicktimeView.
*/
-(int)nodeID
{
    if(_parent)
        return quicktimeObject.GetNodeID();
    else
        return nil;
}

/*
    Sets the current node (by ID) in a QuickTime VR movie (the movie goes to the node with the specified ID). Only works if there is a parent CPQuicktimeView.
    @param a movie id
*/
-(void)setNodeId:(int)aID
{
    if(_parent)
        quicktimeObject.SetNodeID(aID);
}

//Track Properties

/*
    Returns the name of the specified track.
    @param A track index (tracks are listed in numerical order: the first track listed is track 1, the second is track 2, and so on.)
*/
-(CPString)trackName:(int)aIndex
{
    return quicktimeObject.GetTrackName(aIndex);
}

/*
    Returns the type of the specified track, such as video, sound, text, music, sprite, 3D, VR, streaming, movie, Flash, or tween.
    @param A track index (tracks are listed in numerical order: the first track listed is track 1, the second is track 2, and so on.)
*/
-(CPString)trackType:(int)aIndex
{
    return quicktimeObject.GetTrackType(aIndex);
}

/*
    Find out if a track is enabled
    @param A track index (tracks are listed in numerical order: the first track listed is track 1, the second is track 2, and so on.)
*/
-(BOOL)isTrackEnabled:(int)aIndex
{
    return quicktimeObject.GetTrackEnabled(aIndex);
}

/*
    Set the enabled state of a track.
    @param BOOL to decide if the the track should be enabled or disabled
    @param A track index (tracks are listed in numerical order: the first track listed is track 1, the second is track 2, and so on.)
*/
-(void)setEnabled:(BOOL)shouldEnable forTrack:(int)aIndex
{
    quicktimeObject.SetTrackEnabled(aIndex, shouldEnabled);
}

/*
    Get the specified sprite track variable value in the specified track.  
    @param A track index (tracks are listed in numerical order: the first track listed is track 1, the second is track 2, and so on.)
    @param a variable Index
*/
-(CPString)spriteTrackVariableatTrackIndex:(int)tIndex variableIndex:(int)vIndex
{
    return quicktimeObject.GetSpriteTrackVariable(tIndex, vIndex);
}

/*
    Set the specified sprite track variable value in the specified track. Note: You can get and set sprite variable values only in sprite tracks that already have defined variables. You cannot use JavaScript to create a new variable or add it to a track.
    @param a new value
    @param a variable index
    @param A track index (tracks are listed in numerical order: the first track listed is track 1, the second is track 2, and so on.)
*/
-(void)setSpriteVariable:(CPString)aVariable atIndex:(int)vIndex forTrack:(int)tIndex
{
    quicktimeObject.SetSpriteTrackVariable(tIndex, vIndex, aVariable);
}

-(void)notificationBegin
{
    [[CPNotificationCenter defaultCenter] postNotificationName:"qt_begin" object:(_parent?_parent:self)]; 
}

-(void)notificationLoadedMetaData
{
    [[CPNotificationCenter defaultCenter] postNotificationName:"qt_loadedmetadata" object:(_parent?_parent:self)];
}

-(void)notificationLoadedFirstFrame
{
    [[CPNotificationCenter defaultCenter] postNotificationName:"qt_loadedfirstframe" object:(_parent?_parent:self)];
}
-(void)notificationCanPlay
{
    [[CPNotificationCenter defaultCenter] postNotificationName:"qt_canplay" object:(_parent?_parent:self)];
}
-(void)notificationCanPlayThrough
{
    [[CPNotificationCenter defaultCenter] postNotificationName:"qt_canplaythrough" object:(_parent?_parent:self)];
}
-(void)notificationDurationChange
{
    [[CPNotificationCenter defaultCenter] postNotificationName:"qt_durationchange" object:(_parent?_parent:self)];
}
-(void)notificationLoad
{
    [[CPNotificationCenter defaultCenter] postNotificationName:"qt_load" object:(_parent?_parent:self)];
}
-(void)notificationEnded
{
    [[CPNotificationCenter defaultCenter] postNotificationName:"qt_ended" object:(_parent?_parent:self)];
}
-(void)notificationError
{
    [[CPNotificationCenter defaultCenter] postNotificationName:"qt_error" object:(_parent?_parent:self)];
}
-(void)notificationPause
{
    [[CPNotificationCenter defaultCenter] postNotificationName:"qt_pause" object:(_parent?_parent:self)];
}
-(void)notificationPlay
{
    [[CPNotificationCenter defaultCenter] postNotificationName:"qt_play" object:(_parent?_parent:self)];
}
-(void)notificationProgress
{
    [[CPNotificationCenter defaultCenter] postNotificationName:"qt_progress" object:(_parent?_parent:self)];
}
-(void)notificationWating
{
    [[CPNotificationCenter defaultCenter] postNotificationName:"qt_waiting" object:(_parent?_parent:self)];
}
-(void)notificationStalled
{
    [[CPNotificationCenter defaultCenter] postNotificationName:"qt_stalled" object:(_parent?_parent:self)];
}
-(void)notificationTimeChanged
{
    [[CPNotificationCenter defaultCenter] postNotificationName:"qt_timechanged" object:(_parent?_parent:self)];
}
-(void)notificationVolumeChanged
{
    [[CPNotificationCenter defaultCenter] postNotificationName:"qt_volumechange" object:(_parent?_parent:self)];
}

@end

@implementation CPQuicktimeView : CPView
{
    CPQuickTimeController QTController;
}    

- (id)initWithFrame:(CGRect)aFrame contentsOfFile:(CPString)aFile//plays in a view
{
    self = [super initWithFrame:aFrame];
    
    quickTimeObject = [[CPQuicktimeController alloc] initWithFrame:aFrame contentsOfFile:File parent:self];
    
    return self;
}

-(void)addQuickTimeController:(CPString)aQT
{
    _DOMElement.writeln(aQT);
}

//Movie Commands

/*!
    Plays the quicktime object at the default rate, starting from the movie’s current time.
*/
- (BOOL)isPlaying
{
    return [QTController isPlaying];
}

- (void)play
{
    [QTController play];
}

/*!
    Pauses the quicktime object.
*/
- (void)pause
{
    [QTController pause];
}

/*!
    Resumes the quicktime object.
*/
- (void)resume
{
    [QTController resume];
}

/*!
    Stops the quicktime object.
*/
- (void)stop
{
    [QTController stop];
}

/*!
    Sets the current time to the movie’s start time and pauses the movie.
*/
-(void)rewind
{
    [QTController rewind];
}

/*
    Steps the movie forward or backward the specified number of frames from the point at which the command is received. If the movie’s rate is non-zero, it is paused.
    @param the number of steps
*/
-(void)setStep:(int)aCount
{
    [QTController setStep:aCount];
}

/*
    Displays a QuickTime VR movie’s default node, using the default pan angle, tilt angle, and field of view as set by the movie’s author. Only works if there is a parent CPQuicktimeView.
*/
-(void)showDefualtView
{
    [QTController showDefaultView];
}

/*
    Returns to the previous node in a QuickTime VR movie (equivalent to clicking the Back button on the VR movie controller). Only works if there is a parent CPQuicktimeView.
*/
-(void)goPreiousNode
{
    [QTController goPreviosNode];
}

/*
    Takes a chapter name and sets the movie's current time to the beginning of that chapter. See also: GetChapterName and GetChapterCount in movie properties.
    @param the chapter name
*/
-(void)goToChapter:(CPString)aName
{
    [QTController goToChapter:aName];
}

//Quicktime/Plugin Properties

/*
    Returns the version of QuickTime.
*/
-(CPString)quickTimeVersion
{
    return [QTController quickTimeVersion];
}

/*
    Returns the user’s QuickTime language (set through the plug-in’s Set Language dialog).
*/
-(CPString)quickTimeLanguage
{
    return [QTController quickTimeLanguage];
}

/*
    Returns the connection speed setting from the users QuickTime preferences.
*/
-(int)quickTimeConnectionSpeed
{
    return [QTController quickTimeConnectionSpeed];
}

/*
    Returns YES if the user is registered for the Pro version of QuickTime; otherwise returns NO.
*/
-(BOOL)isQuicktimeRegistered
{
    return [QTController isQuicktimeRegistered];
}

/*
    Returns the version of a specific QuickTime component. The component is specified using a four character string for the type, subtype, and manufacturer. For example, to check the version of Apple’s JPEG graphics importer call GetComponentVersion> 'grip','JPEG','appl').'0' is a wildcard for any field. If the component is not available, 0.0 is returned.
    @param four character string for the type
    @param four character string for the sub type
    @param four character string for the manfacturer
*/
-(CPString)componentVersionFromType:(CPString)aType subType:(CPString)aSubType manufacturer:(CPString)aManufacturer
{
    return [QTController componentVersionFromType:aType subType:aSubType manufacturer:aManufacturer];
} 

/*
    Returns the version of the QuickTime plug-in.
*/
-(CPString)pluginVersion
    return [QTController pluginVersion];
}

/*
    Finds out if the movie and plug-in properies are reset when a new movie is loaded. By default, most movie and plug-in properies are reset when a new movie is loaded. For example, when a new movie loads, the default controller setting is true for a linear movie and false for a VR movie, regardless of the prior setting. If this property is set to false, the new movie inherits the settings in use with the current movie.
*/
-(BOOL)doesResetPropertiesOnReload
{
    return [QTController doesResetPropertiesOnReload];
}

/*  
    Sets whether the movie and plug-in properies are reset when a new movie is loaded. By default, most movie and plug-in properies are reset when a new movie is loaded. For example, when a new movie loads, the default controller setting is true for a linear movie and false for a VR movie, regardless of the prior setting. If this property is set to false, the new movie inherits the settings in use with the current movie.
    @param BOOL to decide if the movie and plug-in properies should be reset when a new movie is loaded.
*/             
-(void)setResetPropertiesOnReload:(BOOL)shouldResetPropertiesOnReload
{
    [QTController setResetPropertiesOnRelod:shouldResetPropertiesOnReload];
}

//Movie Properties

/*
    returns a string with the status of the current movie. Possible states are:
    ”Waiting”—waiting for the movie data stream to begin
    ”Loading”—data stream has begun, not able to play/display the movie yet
    ”Playable”—movie is playable, although not all data has been downloaded
    ”Complete”—all data has been downloaded
    ”Error: <error number>”—the movie failed with the specified error number
    Note: Even though the method is named GetPluginStatus it gets the status of a specific movie, not the status of the plug-in as a whole. If more than one movie is embedded in a document, there can be a different status for each movie. For example, one movie could be   playable while another is still loading.
*/
-(CPString)pluginStatus
{
    return [QTController pluginStatus];
}

/* 
    Find out if a movie automatically starts playing as soon as it can.
*/
-(BOOL)doesAutoPlay
{
    return [QTController doesAutoPlay];
}

/*
    Sets whether a movie automatically starts playing as soon as it can. This method is roughly equivalent to setting the AUTOPLAY parameter in the <EMBED> tag, but the @HH:MM:SS:FF feature is not yet supported in JavaScript.
    @param BOOl to decide if the movie should autoplay
*/
-(void)setAutoPlay:(BOOL)shouldAutoPlay
{
    [QTController setAutoPlay:shouldAutoPlay];
}

/*
    Find out if a movie has a visible controller. Only works if there is a parent CPQuicktimeView.
*/
-(BOOL)hasVisibleController
{
    return [QTController hasVisibleController];
}

/* 
    Sets whether a movie has a visible controller. This method is equivalent to setting the CONTROLLER parameter in the <EMBED> tag. Only works if there is a parent CPQuicktimeView.
    @param BOOL to set whether a movie has a visible controller
*/
-(void)setHasVisibleController:(BOOL)shouldHaveVisibleController       
{
    [QTController setHasVisibleController:shouldHaveVisibleController];
}

/*
    Find out the playback rate of the movie. A rate of 1 is the normal playback rate. A paused movie has a rate of 0. Fractional values are slow motion, and values greater than one are fast-forward. Negative values indicate that the movie is playing backward.
    Note: Rate goes to zero when the movie finishes playing or is stopped (by the user, for example). You can use the time: and duration: methods to determine whether the movie is stopped at the end, the beginning (time zero), or at some point in between. You may also want the call GetIsLooping to determine whether the movie will end spontaneously.
*/
-(float)rate
{
    return [QTController rate];
}

/* Sets the playback rate of the movie. A rate of 1 is the normal playback rate. A paused movie has a rate of 0. Fractional values are slow motion, and values greater than one are fast-forward. Negative values indicate that the movie is playing backward. Setting the rate of a paused movie to a nonzero value starts the movie playing.
    @param BOOL to Set the playback rate of the movie
*/  
-(void)setRate:(float)aRate
{
    [QTController setRate:aRate];
}


/*
    Get the current time of a movie.
*/
-(int)currentTime
{
    return [QTController currentTime];
}

/*
    Set the current time of a movie. Setting this property causes a movie to go to that time in the movie and stop.
    @param a time the movie should go to.
*/
-(void)setCurrentTime:(int)aTime
{
    [QTController setCurrentTime:aTime];
}

/*
    Get the audio volume of the movie. A negative value mutes the movie.
*/
-(int)volume
{
    return [QTController volume];
}

/*
    Set the audio volume of the movie. A negative value mutes the movie. The Set method is equivalent to setting the VOLUME parameter in the <EMBED> tag.
    @param a new volume
*/
-(void)setVolume:(int)aVolume
{
    [QTController setVolume:aVolume];
}

/* 
    Find out whether the volume is muted.
*/
-(BOOL)isMuted
{
    return [QTController isMuted];
}

/* 
    Set the audio mute of a movie while maintaining the magnitude of the volume, so turning mute off restores the volume.
    @param BOOl to decide to mute the audio
*/
-(void)setIsMuted:(BOOL)shouldMute
{
    [QTController setIsMuted:shouldMute];
}    

/*
    Get the name that can be used by a wired sprite when targeting an external movie.
*/
-(CPString)name
{
    return [QTController name];
}

/* 
    Set a name that can be used by a wired sprite when targeting an external movie. The Set method is equivalent to setting the MOVIENAME parameter in the <EMBED> tag.
    @param a new movie name
*/
-(void)setName:(CPString)name
{
    [QTController setName:name];
}

/*
    Get the ID that can be used by a wired sprite when targeting an external movie. Note: MovieID is not the same as the NAME parameter in the <EMBED> tag or the id parameter in the <OBJECT> tag. MovieID is used for wired sprite addressing, not JavaScript addressing.
*/
-(int)movieID
{
    return [QTController movieID];
}

/*
    Set an ID that can be used by a wired sprite when targeting an external movie. The Set method is equivalent to setting the MOVIEID parameter in the <EMBED> tag. Note: MovieID is not the same as the NAME parameter in the <EMBED> tag or the id parameter in the <OBJECT> tag. MovieID is used for wired sprite addressing, not JavaScript addressing.
    @param a new movie id integer
*/
-(void)setMovieID:(int)aID
{
    [QTController setMovieID:aID];
}

/*
    Returns the number of chapters in the movie.
*/
-(void)chapterCount
{
    return [QTController chapterCount];
}

/*
    Takes a chapter number and returns the chapter name.
    @param a chapter number
*/
-(CPString)chapterNameFromNumber:(int)aChapter
{
    return [QTController chapterNameFromNumber:(int)aChapter];
}

/*
    Get the time at which a movie begins to play and the time at which it stops or loops when playing in reverse. Initially, the start time of a movie is set to 0 unless specified in the STARTTIME parameter in the <EMBED> tag.          
*/
-(int)startTime
{
    return [QTController startTime];
}

/*
    Set the time at which a movie begins to play and the time at which it stops or loops when playing in reverse. Initially, the start time of a movie is set to 0 unless specified in the STARTTIME parameter in the <EMBED> tag. The start time cannot be set to a time greater than the end time. The Set method is equivalent to setting the STARTTIME parameter in the <EMBED> tag.  
    @param a new start time
*/
-(void)setStartTime:(int)aTime
{
    [QTController setStartTime:aTime];
}

/*
    Get the time at which a movie stops playing or loops. The end time of a movie is initially set to its duration, unless specified in the ENDTIME parameter in the <EMBED> tag.    
*/
-(int)endTime
{
    return [QTController endTime];
}

/*
    Set and set the time at which a movie stops playing or loops. The end time of a movie is initially set to its duration, unless specified in the ENDTIME parameter in the <EMBED> tag. The end time cannot be set to a time greater than the movie’s duration. The Set method is equivalent to setting the ENDTIME parameter in the <EMBED> tag.
    @param a new end time
*/ 
-(void)setEndTime:(int)aTime
{
    return [QTController setEndTime:aTime];
}

/*
    Get the color used to fill any space allotted to the plug-in by the <EMBED> tag and not covered by the movie. Regardless of the syntax used to specify the color, GetBgColor() always returns the color as a number—for example, if the background color is set to Navy, bgColor: returns #000080. Only works if there is a parent CPQuicktimeView.
*/
-(CPString)bgColor
{
    return [QTController bgColor];
}    

/*
    Find out whether a movie loops when it reaches its end. A movie can loop either by restarting when it reaches the end or by playing backward when it reaches the end, then restarting when it reaches the beginning, depending on the LoopIsPalindrome value.
*/
-(BOOL)isLooping
{
    return [QTController isLooping];
}

/*
    Set whether a movie loops when it reaches its end. A movie can loop either by restarting when it reaches the end or by playing backward when it reaches the end, then restarting when it reaches the beginning, depending on the LoopIsPalindrome value. Using the SetIsLooping method is equivalent to setting the LOOP parameter to true or false in the <EMBED> tag.
    @param BOOL to set looping
*/
-(void)setIsLooping:(BOOL)doesLoop
{
    [QTController setIsLooping:doesLoop];
}

/*
    Find out whether a looping movie reverses direction when it loops, alternately playing backward and forward. The loop property must be true for this to have any effect.
*/
-(BOOL)loopsIsPalindrome
{
    return [QTController loopIsPalindrome];
}

/* 
    Set whether a looping movie reverses direction when it loops, alternately playing backward and forward. The loop property must be true for this to have any effect. Setting both IsLooping and LoopIsPalindrome to true is equivalent to setting the LOOP parameter to Palindrome in the <EMBED> tag.
    @param BOOL to set whether a looping movie reverses direction when it loops
*/
-(void)setLoopsIsPalindrome:(BOOL)shouldLoopPalindrome
{
    [QTController setLoopIsPalindrome:shouldLoopPalindrome];
}

/* 
    Find out whether QuickTime should play every frame in a movie even if it gets behind (playing in slow motion rather than dropping frames). The sound is muted when playAll is set true.
*/
-(BOOL)doesPlayEveryFrame
{
    return [QTController doesPlayEveryFrame];
}

/*
    Set whether QuickTime should play every frame in a movie even if it gets behind (playing in slow motion rather than dropping frames). The sound is muted when playAll is set true. The Set method is equivalent to setting the PLAYEVERYFRAME parameter in the <EMBED> tag.
    @param BOOL to determine whetjer the movie should play every frame
*/
-(void)setPlayEveryFrame:(BOOL)shouldPlayEveryFrame
{
    [QTController setPlayEveryFrame:shouldPlayEveryFrame];
}

/*
    Get the URL that is invoked by a mouse click in a movie’s display area. The URL can specify a web page, a QuickTime movie, a live streaming session, or be a JavaScript function name.    
*/
-(CPString)movieHREF
{
    return [QTController movieHREF];
}

/*
    Set the URL that is invoked by a mouse click in a movie’s display area. The URL can specify a web page, a QuickTime movie, a live streaming session, or be a JavaScript function name. The Set method is equivalent to setting the HREF parameter in the <EMBED> tag.
    @param a new url
*/
-(void)setMovieHREF:(CPString)aURL
{
    [QTController setMovieHREF:aURL];
}

/*
    Get the target for a movie’s HREF parameter. The target can be an existing frame or browser window, a new browser window, myself (the QuickTime plug-in), or quicktimeplayer.     
*/
-(CPString)movieTarget
{
    return [QTController movieTarget];
}

/*
    Set the target for a movie’s HREF parameter. The target can be an existing frame or browser window, a new browser window, myself (the QuickTime plug-in), or quicktimeplayer. The Set method is equivalent to setting the TARGET parameter in the <EMBED> tag.           
    @param a new target
*/
-(void)setMovieTarget:(CPString)aTarget
{
    [QTController setMovieTarget:aTarget];
}

/*
    Get the URL and target for a specified item in a sequence. The URL of the first item in the sequence is invoked when the currently selected movie finishes. If the URL specifies a QuickTime movie and the special target myself, the next specified URL in the sequence is invoked when that movie finishes, and so on.
    @param an Index for a next url
*/
-(CPString)nextURLForIndex:(int)aIndex
{
    return [QTController nextURLForIndex:aIndex];
}         
         
/*
    Set the URL and target for a specified item in a sequence. The URL of the first item in the sequence is invoked when the currently selected movie finishes. If the URL specifies a QuickTime movie and the special target myself, the next specified URL in the sequence is invoked when that movie finishes, and so on. The Set method is equivalent to setting the QTNEXTn parameter in the <EMBED> tag.
    @param an Index for a next URL
    @param a url for the next url
*/
-(void)setNextUrlForIndex:(int)aIndex url:(CPString)aURL
{
    [QTController setNextUrlForIndex:aIndex url:aURL];
}

/*
   Returns a movie’s full URL.
*/
-(CPString)movieURL
{
    return [QTController movieURL];
}

/*
    Replaces a movie with another movie specified by the URL.
    @param a new URL
*/
-(void)setMovieURL:(CPString)aURL
{
    [QTController setMovieURL:aURL];
}

/*
    Find out whether kiosk mode is currently set. In kiosk mode, the QuickTime plug-in does not allow the viewer to save a movie to disk. Only works if there is a parent CPQuicktimeView.
*/
-(BOOL)isKioskMode
{
    return [QTController isKioskMode];
}  

/* 
    Set whether kiosk mode is currently set. In kiosk mode, the QuickTime plug-in does not allow the viewer to save a movie to disk. Setting kioskMode to true is equivalent to setting the KIOSKMODE parameter in the <EMBED> tag. Only works if there is a parent CPQuicktimeView.
    @param BOOL to enable Kiosk Mode
*/
-(void)setKioskMode:(BOOL)shouldEnableKiosk
{
    [QTController setKioskMode:shouldEnableKiosk];
}

/*
    Returns the length of the movie (in the movie’s time scale units).
*/
-(int)duration
{
    return [QTController duration];
}

/*
    Returns the amount of the movie that has been downloaded (in the movie’s time scale units).
*/
-(int)maxTimeLoaded
{
    return [QTController maxTimeLoaded];
}

/*
    Returns the time scale of the movie in units per second. For example, if GetTimeScale() returns 30, each movie time scale unit represents 1/30 of a second.
*/
-(int)timeScale
{
    return [QTController timeScale];
}

/*
    Returns the size of the movie in bytes.
*/
-(int)movieSize
{
    return [QTController movieSize];
}

/*
    Returns the number of bytes of the movie that have been downloaded.
*/
-(int)maxBytesLoaded
{
    return [QTController maxBytesLoaded];
}

/*
    Returns the total number of tracks in the movie.
*/
-(int)trackCount
{
    return [QTController trackCount];
}

/*
    Get a movie’s transformation matrix.
    @param class of which you want the matrix to be of, either CPString or CPArray
*/                             
-(id)matrixOfClass:(Class)aClass
{
    return [QTController matrixOfClass:aClass];
}

/*
    Set a movie’s transformation matrix.
*/
-(void)setMatrix:(id)aMatrix
{
    [QTController setMatrix:aMatrix];
}

/*
    Get the movie’s current language. Supported language names: Albanian, Arabic, Belorussian
Bulgarian
Croatian
Czech
Danish
Dutch
English
Estonian
Faeroese
Farsi
Finnish
Flemish
French
German
Greek
Hebrew
Hindi
Hungarian
Icelandic
Irish
Italian
Japanese
Korean
Latvian
Lithuanian
Maltese
Norwegian
Polish
Portuguese
Romanian
Russian
Saamisk
Serbian
Simplified Chinese
Slovak
Slovenian
Spanish
Swedish
Thai
Traditional Chinese
Turkish
Ukrainian
Urdu
Yiddish
*/
-(CPString)language
{
    [QTController language];
}

/*
    Set the movie’s current language. Setting the language causes any tracks associated with that language to be enabled and tracks associated with other languages to be disabled. If no tracks are associated with the specified language, the movie’s language is not changed.

Supported language names:

Albanian
Arabic
Belorussian
Bulgarian
Croatian
Czech
Danish
Dutch
English
Estonian
Faeroese
Farsi
Finnish
Flemish
French
German
Greek
Hebrew
Hindi
Hungarian
Icelandic
Irish
Italian
Japanese
Korean
Latvian
Lithuanian
Maltese
Norwegian
Polish
Portuguese
Romanian
Russian
Saamisk
Serbian
Simplified Chinese
Slovak
Slovenian
Spanish
Swedish
Thai
Traditional Chinese
Turkish
Ukrainian
Urdu
Yiddish
    @param a new language
*/
-(void)setLanguage:(CPString)aLanguage
{
    [QTController setLanguage:aLaunguage];
}

/*
    Returns the movie’s MIME type.
*/
-(CPString)MIMEType
{
    return [QTController MIMEType];
}

/*
    Returns the movie user data text with the specified tag. The tag is specified with a four-character string; for example, '©cpy' returns a movie’s copyright string. The following table contains a list of user data tags.
    '©nam', Movie’s name
    '©cpy', Copyright statement
    '©day', Date the movie content was created
    '©dir', Name of movie’s director
    '©ed1' to '© ed9', Edit dates and descriptions
    '©fmt', Indication of movie format (computer-generated, digitized, and so on)
    '©inf', Information about the movie
    '©prd', Name of movie’s producer
    '©prf', Names of performers
    '©req', Special hardware and software requirements
    '©src', Credits for those who provided movie source content
    '©wrt', Name of movie’s writer
    @param type of user data
*/
-(CPString)userDataOfType:(CPString)aType
{
    return [QTController userDataOfType:aType];
}

/*
    Returns true if the movie is a QuickTime VR movie, false otherwise. Only works if there is a parent CPQuicktimeView.
*/
-(BOOL)isVRMovie
{
    return [QTController isVRMovie];
}

//VR Movie Properties

/*
    Get the URL associated with a specified VR movie hot spot. Only works if there is a parent CPQuicktimeView.
    @param A Hotpot ID
*/
-(CPString)hotpotURLForID:(int)aID
{
    return [QTController hotpotURLForID:aID];
}

/*
    Set the URL associated with a specified VR movie hot spot. The Set method is equivalent to setting the HOTSPOTn parameter in the <EMBED> tag. Only works if there is a parent CPQuicktimeView.
    @param A Hotspot ID
    @param A Hotspot URL
*/
-(void)setHotspotForID:(int)aID url:(CPString)aURL
{
    [QTController setHotspotForID:aID url:aURL];
}

/*
    Get the target for a specified VR movie hot spot. Only works if there is a parent CPQuicktimeView.
    @param A Hotspot ID
*/
-(CPString)hotspotTargetForID:(int)aID
{
    [QTController hotspotTargetForID:aID];
}

/*
    Set the target for a specified VR movie hot spot. The Set method is equivalent to setting the TARGETn parameter in the <EMBED> tag. Only works if there is a parent CPQuicktimeView.
    @param A Hotspot ID
*/
-(void)setHotspotTagetForID:(int)aID target:(CPString)aTarget
{
    [QTController setHotspotTaget:aID target:aTarget];
}

/*
    Get QuickTime VR movie’s pan angle (in degrees). Only works if there is a parent CPQuicktimeView.
*/
-(float)panAngle
{
    return [QTController panAngle];
}

/*
    Set the QuickTime VR movie’s pan angle (in degrees). The Set method is equivalent to setting the PAN parameter in the <EMBED> tag. Only works if there is a parent CPQuicktimeView.
    @param a new pan angle
*/
-(void)setPanAngle:(float)aAngle
{
    [QTController setPanAngle:aAngle];
}

/*
    Get the QuickTime VR movie’s tilt angle (in degrees). Only works if there is a parent CPQuicktimeView.
*/
-(float)tiltAngle
{
    return [QTController tileAngle];
}

/*
    Set the QuickTime VR movie’s tilt angle (in degrees).The Set method is equivalent to setting the TILT parameter in the <EMBED> tag. Only works if there is a parent CPQuicktimeView.
    @param a new tilt angle
*/
-(void)setTiltAngle:(float)aAngle
{
    [QTController setTiltAngle:aAngle];
}

/*
    Get and set the QuickTime VR movie’s field of view (in degrees). Only works if there is a parent CPQuicktimeView.
*/
-(float)fieldOfView
{
    [QTController fieldOfView];
}

/*
    Set the QuickTime VR movie’s field of view (in degrees). Setting a narrower field of view causes the VR to “zoom in.” Setting a wider field of view causes the VR to “zoom out.” The Set method is equivalent to setting the FOV parameter in the <EMBED> tag.
    Only works if there is a parent CPQuicktimeView.
    @param a new field of view
*/    
-(void)setFieldOfView:(float)aView
{
    [QTController setFieldOfView:aView];
}

/*
    Returns the number of nodes in a QuickTime VR movie. Only works if there is a parent CPQuicktimeView.
*/
-(int)nodeCount
{
    return [QTController nodeCount];
}

/*
    Returns the ID of the current node in a QuickTime VR movie. Only works if there is a parent CPQuicktimeView.
*/
-(int)nodeID
{
    return [QTController nodeID];
}

/*
    Sets the current node (by ID) in a QuickTime VR movie (the movie goes to the node with the specified ID). Only works if there is a parent CPQuicktimeView.
    @param a movie id
*/
-(void)setNodeId:(int)aID
{
    [QTController setNodeId:aID];
}

//Track Properties

/*
    Returns the name of the specified track.
    @param A track index (tracks are listed in numerical order: the first track listed is track 1, the second is track 2, and so on.)
*/
-(CPString)trackName:(int)aIndex
{
    return [QTController trackName:aIndex];
}

/*
    Returns the type of the specified track, such as video, sound, text, music, sprite, 3D, VR, streaming, movie, Flash, or tween.
    @param A track index (tracks are listed in numerical order: the first track listed is track 1, the second is track 2, and so on.)
*/
-(CPString)trackType:(int)aIndex
{
    return [QTController trackType:aIndex];
}

/*
    Find out if a track is enabled
    @param A track index (tracks are listed in numerical order: the first track listed is track 1, the second is track 2, and so on.)
*/
-(BOOL)isTrackEnabled:(int)aIndex
{
    return [QTController isTrackEnabled:aIndex];
}

/*
    Set the enabled state of a track.
    @param BOOL to decide if the the track should be enabled or disabled
    @param A track index (tracks are listed in numerical order: the first track listed is track 1, the second is track 2, and so on.)
*/
-(void)setEnabled:(BOOL)shouldEnable forTrack:(int)aIndex
{
    [QTController setEnabled:(BOOL)shouldEnable forTrack:aIndex];
}

/*
    Get the specified sprite track variable value in the specified track.  
    @param A track index (tracks are listed in numerical order: the first track listed is track 1, the second is track 2, and so on.)
    @param a variable Index
*/
-(CPString)spriteTrackVariableatTrackIndex:(int)tIndex variableIndex:(int)vIndex
{
    return [QTController spriteTrackVariableatTrackIndex:tIndex variableIndex:vIndex];
}

/*
    Set the specified sprite track variable value in the specified track. Note: You can get and set sprite variable values only in sprite tracks that already have defined variables. You cannot use JavaScript to create a new variable or add it to a track.
    @param a new value
    @param a variable index
    @param A track index (tracks are listed in numerical order: the first track listed is track 1, the second is track 2, and so on.)
*/
-(void)setSpriteVariable:(CPString)aVariable atIndex:(int)vIndex forTrack:(int)tIndex
{
    [QTController setSpriteVariable:aVariable atIndex:vIndex forIndex:tIndex];
}

@end

/*

File: AC_QuickTime.js

Abstract: This file contains functions to generate OBJECT and EMBED tags for QuickTime content.

Version: <1.1>

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Computer, Inc. ("Apple") in consideration of your agreement to the
following terms, and your use, installation, modification or
redistribution of this Apple software constitutes acceptance of these
terms.  If you do not agree with these terms, please do not use,
install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software. 
Neither the name, trademarks, service marks or logos of Apple Computer,
Inc. may be used to endorse or promote products derived from the Apple
Software without specific prior written permission from Apple.  Except
as expressly stated in this notice, no other rights or licenses, express
or implied, are granted by Apple herein, including but not limited to
any patent rights that may be infringed by your derivative works or by
other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright © 2006 Apple Computer, Inc., All Rights Reserved

*/ 

/*
 * This file contains functions to generate OBJECT and EMBED tags for QuickTime content. 
 */

/************** LOCALIZABLE GLOBAL VARIABLES ****************/

var gArgCountErr =	'The "%%" function requires an even number of arguments.'
				+	'\nArguments should be in the form "atttributeName", "attributeValue", ...';

/******************** END LOCALIZABLE **********************/

var gTagAttrs				= null;
var gQTGeneratorVersion		= 1.0;

function AC_QuickTimeVersion()	{ return gQTGeneratorVersion; }

function _QTComplain(callingFcnName, errMsg)
{
    errMsg = errMsg.replace("%%", callingFcnName);
	alert(errMsg);
}

function _QTAddAttribute(prefix, slotName, tagName)
{
	var		value;

	value = gTagAttrs[prefix + slotName];
	if ( null == value )
		value = gTagAttrs[slotName];

	if ( null != value )
	{
		if ( 0 == slotName.indexOf(prefix) && (null == tagName) )
			tagName = slotName.substring(prefix.length); 
		if ( null == tagName ) 
			tagName = slotName;
		return '' + tagName + '="' + value + '"';
	}
	else
		return "";
}

function _QTAddObjectAttr(slotName, tagName)
{
	// don't bother if it is only for the embed tag
	if ( 0 == slotName.indexOf("emb#") )
		return "";

	if ( 0 == slotName.indexOf("obj#") && (null == tagName) )
		tagName = slotName.substring(4); 

	return _QTAddAttribute("obj#", slotName, tagName);
}

function _QTAddEmbedAttr(slotName, tagName)
{
	// don't bother if it is only for the object tag
	if ( 0 == slotName.indexOf("obj#") )
		return "";

	if ( 0 == slotName.indexOf("emb#") && (null == tagName) )
		tagName = slotName.substring(4); 

	return _QTAddAttribute("emb#", slotName, tagName);
}


function _QTAddObjectParam(slotName, generateXHTML)
{
	var		paramValue;
	var		paramStr = "";
	var		endTagChar = (generateXHTML) ? ' />' : '>';

	if ( -1 == slotName.indexOf("emb#") )
	{
		// look for the OBJECT-only param first. if there is none, look for a generic one
		paramValue = gTagAttrs["obj#" + slotName];
		if ( null == paramValue )
			paramValue = gTagAttrs[slotName];

		if ( 0 == slotName.indexOf("obj#") )
			slotName = slotName.substring(4); 
	
		if ( null != paramValue )
			paramStr = '<param name="' + slotName + '" value="' + paramValue + '"' + endTagChar;
	}

	return paramStr;
}

function _QTDeleteTagAttrs()
{
	for ( var ndx = 0; ndx < arguments.length; ndx++ )
	{
		var attrName = arguments[ndx];
		delete gTagAttrs[attrName];
		delete gTagAttrs["emb#" + attrName];
		delete gTagAttrs["obj#" + attrName];
	}
}

		

// generate an embed and object tag, return as a string
function _QTGenerate(callingFcnName, generateXHTML, args)
{
	// is the number of optional arguments even?
	if ( args.length < 4 || (0 != (args.length % 2)) )
	{
		_QTComplain(callingFcnName, gArgCountErr);
		return "";
	}
	
	// allocate an array, fill in the required attributes with fixed place params and defaults
	gTagAttrs = new Object();
	gTagAttrs["src"] = args[0];
	gTagAttrs["width"] = args[1];
	gTagAttrs["height"] = args[2];
	gTagAttrs["classid"] = "clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B";
		//Impportant note: It is recommended that you use this exact classid in order to ensure a seamless experience for all viewers
	gTagAttrs["pluginspage"] = "http://www.apple.com/quicktime/download/";

	// set up codebase attribute with specified or default version before parsing args so
	//  anything passed in will override
	var activexVers = args[3]
	if ( (null == activexVers) || ("" == activexVers) )
		activexVers = "6,0,2,0";
	gTagAttrs["codebase"] = "http://www.apple.com/qtactivex/qtplugin.cab#version=" + activexVers;

	var	attrName,
		attrValue;

	// add all of the optional attributes to the array
	for ( var ndx = 4; ndx < args.length; ndx += 2)
	{
		attrName = args[ndx].toLowerCase();
		attrValue = args[ndx + 1];

		// "name" and "id" should have the same value, the former goes in the embed and the later goes in
		//  the object. use one array slot 
		if ( "name" == attrName || "id" == attrName )
			gTagAttrs["name"] = attrValue;

		else 
			gTagAttrs[attrName] = attrValue;
	}

	// init both tags with the required and "special" attributes
	var objTag =  '<object '
					+ _QTAddObjectAttr("classid")
					+ _QTAddObjectAttr("width")
					+ _QTAddObjectAttr("height")
					+ _QTAddObjectAttr("codebase")
					+ _QTAddObjectAttr("name", "id")
					+ _QTAddObjectAttr("tabindex")
					+ _QTAddObjectAttr("hspace")
					+ _QTAddObjectAttr("vspace")
					+ _QTAddObjectAttr("border")
					+ _QTAddObjectAttr("align")
					+ _QTAddObjectAttr("class")
					+ _QTAddObjectAttr("title")
					+ _QTAddObjectAttr("accesskey")
					+ _QTAddObjectAttr("noexternaldata")
					+ '>'
					+ _QTAddObjectParam("src", generateXHTML);
	var embedTag = '<embed '
					+ _QTAddEmbedAttr("src")
					+ _QTAddEmbedAttr("width")
					+ _QTAddEmbedAttr("height")
					+ _QTAddEmbedAttr("pluginspage")
					+ _QTAddEmbedAttr("name")
					+ _QTAddEmbedAttr("align")
					+ _QTAddEmbedAttr("tabindex");

	// delete the attributes/params we have already added
	_QTDeleteTagAttrs("src","width","height","pluginspage","classid","codebase","name","tabindex",
					"hspace","vspace","border","align","noexternaldata","class","title","accesskey");

	// and finally, add all of the remaining attributes to the embed and object
	for ( var attrName in gTagAttrs )
	{
		attrValue = gTagAttrs[attrName];
		if ( null != attrValue )
		{
			embedTag += _QTAddEmbedAttr(attrName);
			objTag += _QTAddObjectParam(attrName, generateXHTML);
		}
	} 

	// end both tags, we're done
	return objTag + embedTag + '></em' + 'bed></ob' + 'ject' + '>';
}

// return the object/embed as a string
function QT_GenerateOBJECTText()
{
	return _QTGenerate("QT_GenerateOBJECTText", false, arguments);
}

function QT_GenerateOBJECTText_XHTML()
{
	return _QTGenerate("QT_GenerateOBJECTText_XHTML", true, arguments);
}

function QT_WriteOBJECT()
{
	document.writeln(_QTGenerate("QT_WriteOBJECT", false, arguments));
}

function QT_WriteOBJECT_XHTML()
{
	document.writeln(_QTGenerate("QT_WriteOBJECT_XHTML", true, arguments));
}
