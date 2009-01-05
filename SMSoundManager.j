//
//  SMSoundManager.j
//  SoundManager
//
//  Created by Ross Boucher on 10/3/08.
//  Copyright 280 North 2008. All rights reserved.
//

@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>

@implementation SMSoundManager : CPObject
{
    BOOL    _isLoaded;
    Object  soundManager;
}

- (id)init
{
    self = [super init];
    CPLog("Inicializando el SM");
    window.setTimeout(setupSoundManager, 1000, self);
    
    return self;
}

- (void)soundManagerDidLoad:(Object)aManager
{
    _isLoaded = YES;
    soundManager = aManager;
}

- (void)playSound:(CPString)aFile
{
    var song = soundManager.createSound({ 
		id : 'aSong', 
		url : aFile,
		onfinish: function(){
			[self soundDidFinish];
        },
		whileplaying: function(){
			[self soundPosition];
		}
	});
	song.play();
}

-(void)pauseSound{
	soundManager.pause('aSong');
}

-(void)resumeSound{
	soundManager.resume('aSong');
}

-(void)togglePause{
	soundManager.togglePause('aSong');
}

-(void)stopSound{
    soundManager.destroySound('aSong');
}

-(BOOL)isLoaded
{
    CPLog(_isLoaded);
	return _isLoaded;
}

-(void)setVolume:(int)aVolume{
    soundManager.setVolume('aSong', aVolume);
}

-(void)soundDidFinish{
	 CPLog("Sound finished...posting notification...");
	 [[CPNotificationCenter defaultCenter] postNotificationName:"SongEnded" object:self]; 
}

-(void)soundPosition{

	CPLog("sound position notification posting");
	CPLog("pos: " + soundManager.getSoundById('aSong').position);
	//CPLog("position: " + pos);
	var info = [[CPDictionary alloc] init];
	[info setObject:soundManager.getSoundById('aSong').position forKey:"time"];
	CPLog(info);   
	[[CPNotificationCenter defaultCenter] postNotificationName:"pos" object:self userInfo:info]; 
}

-(void)setSoundPosition:(int)pos{
    soundManager.setPosition('aSong',pos);
}

@end

var setupSoundManager = function(obj)
{
	var script = document.createElement("script");
	
	script.type = "text/javascript";
	script.src = "Resources/SoundManager/soundmanager2.js?user=Guest&pass=";
	
	script.addEventListener("load", function()
	{
		soundManager.url = "Resources/SoundManager/"; // path to directory containing SoundManager2 .SWF file
		soundManager.onload = function() {
            [obj soundManagerDidLoad:soundManager];   
		};
        soundManager.beginDelayedInit();
		soundManager.debugMode = false;
	}, YES);	
	
	document.getElementsByTagName("head")[0].appendChild(script);
}