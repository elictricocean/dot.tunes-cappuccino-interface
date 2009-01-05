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

@implementation DTCoverFlow : CPView
{
    Object Coverflow;
    DOMObject CoverFlowScript;
    DOMObject coverFlowView;
    DOMObject coverFlowViewWrapper;
    DOMObject coverFlowViewLabel;
    CPArray model;
}

- (id)initWithFrame:(CGRect)aFrame model:(CPArray)aModel
{
    self = [super initWithFrame:aFrame];
    [self setBackgroundColor:[CPColor blackColor]];
    model = aModel;
    
    coverFlowView = document.createElement("div");
	coverFlowView.setAttribute('id', '__cvfl-coverflow');
	coverFlowView.style.height=CPRectGetHeight([self frame]);//300
	coverFlowView.style.margin="auto";
	coverFlowView.style.overflow="hidden";
	coverFlowView.style.position="relative";
	coverFlowView.style.width = CPRectGetWidth([self frame]);
	
	coverFlowViewWrapper = document.createElement("div");
	coverFlowViewWrapper.setAttribute('id', '__cvfl-coverflow-wrapper');
	coverFlowViewWrapper.style.position="absolute";
	
	coverFlowViewLabel = document.createElement("div");
	coverFlowViewLabel.setAttribute('id', '__cvfl-coverflow-label');
	coverFlowViewLabel.style.color="#fff";
	coverFlowViewLabel.style.font="14pt Lucida Grande, Lucida Sans Unicode";
	coverFlowViewLabel.style.lineHeight="1.3em";
	coverFlowViewLabel.style.position="relative";
	coverFlowViewLabel.style.textAlign="center";
	coverFlowViewLabel.style.top="273px";
	coverFlowViewLabel.style.zIndex="700px";
	
	coverFlowView.appendChild(coverFlowViewWrapper);
    coverFlowView.appendChild(coverFlowViewLabel);
    //document.getElementsByTagName("body")[0].appendChild(coverFlowView);
    
    //_DOMElement.removeChild(_iframe);

    //CPDOMDisplayServerAppendChild(_DOMElement, coverFlowView);
    _DOMElement.appendChild(coverFlowView);
    
    //[self setModel:model];
    
    CPLog(_DOMElement);
    console.log("initialzing coverflows");
    //window.setTimeout(setupCoverFlow, 1000, self);
    
    //CoverFlowScript = document.createElement("script");
	
	//CoverFlowScript.type = "text/javascript";
	//CoverFlowScript.src = "coverflow.js?user=Guest&pass=";
	
	//document.getElementsByTagName("head")[0].appendChild(CoverFlowScript);	    
	    
    return self;
}

- (void)coverFlowDidLoad:(Object)aFlow
{
    Coverflow = aFlow;
    console.log(Coverflow);
    console.log("Yup loaded");
   
	[self setModel:model];
	//_DOMElement.appendChild(document.getElementById('__cvfl-coverflow'));
}

-(void)setModel:(CPArray)aModel
{
    if(model != aModel)
        model = aModel;
        
    if(window.addEventListener)
    {
	   coverFlowView.addEventListener('DOMMouseScroll', Coverflow.wheel.bind(Coverflow), false);
	   window.addEventListener('keydown', CVFLLeftRight, false);
    }
    coverFlowView.onmousewheel = Coverflow.wheel.bind(Coverflow);
    
    //coverFlowView.wrapperAnim.options.onComplete = function(){ Coverflow.init(); };
	//coverFlowView.wrapperAnim.start({opacity: [0]});
    
	/*var evalString = "";
	
	for(i=0; i<[aModel count]; i++)
	{
	   [evalString stringByAppendingString:[CPString stringWithFormat:"{src: '%@', label: {album: '%@', artist: '%@'}}%@", [[aModel objectAtIndex:i] objectForKey:"image"], [[aModel objectAtIndex:i] objectForKey:"album"], [[aModel objectAtIndex:i] objectForKey:"artist"], (i<([aModel count]-1)?",":""), nil]];
    }
	
	eval("coverFlowView.init(["+evalString+"], {createLabel:function(item){ return item.label.album +'<br>'+ item.label.artist; }, onSelectCenter: function(item, id){ var info = [[CPDictionary alloc] init]; [info setObject:[CPArray arrayWithObjects:item,id,nil] forKey:\"info\"]; [[CPNotificationCenter defaultCenter] postNotificationName:\"CoverflowClicked\" object:self userInfo:info]; }});");*/

	
	Coverflow.init(
	[
		{src: 'img/img-0-lo.jpg', label: {album: 'All That I Am', artist: 'Santana'}},
		{src: 'img/img-1-lo.jpg', label: {album: 'August & Everything After', artist: 'Counting Crows'}},
		{src: 'img/img-2-lo.jpg', label: {album: 'Back to Bedlam', artist: 'James Blunt'}},
		{src: 'img/img-3-lo.jpg', label: {album: 'Carnival of Rust', artist: 'Poets of the Fall'}},
		{src: 'img/img-4-lo.jpg', label: {album: 'Collision Course', artist: 'Linkin Park'}},
		{src: 'img/img-5-lo.jpg', label: {album: 'Crossfade', artist: 'Crossfade'}},
		{src: 'img/img-6-lo.jpg', label: {album: 'Dexter', artist: 'Rolfe Kent'}},
		{src: 'img/img-7-lo.jpg', label: {album: 'Life for Rent', artist: 'Dido'}},
		{src: 'img/img-8-lo.jpg', label: {album: 'Say I Am You', artist: 'The Weepies'}},
		{src: 'img/img-9-lo.jpg', label: {album: 'Signs of Life', artist: 'Poets of the Fall'}},
		{src: 'img/img-10-lo.jpg', label: {album: 'Viva la Vida', artist: 'Coldplay'}},
		{src: 'img/img-11-lo.jpg', label: {album: 'We Were Here', artist: 'Joshua Radin'}}
	], 
	{
		createLabel: function(item)
		{
			return item.label.album +'<br>'+ item.label.artist;
		},
	
		onSelectCenter: function(item, id)
		{
           var info = [[CPDictionary alloc] init];
	       [info setObject:[CPArray arrayWithObjects:item,id,nil] forKey:"info"];
	       [[CPNotificationCenter defaultCenter] postNotificationName:"CoverflowClicked" object:self userInfo:info]; 
		}
	});
	//_DOMElement.appendChild(document.getElementById('__cvfl-coverflow'));
}  


@end 

var setupCoverFlow = function(obj)
{
	var script = document.createElement("script");
	
	script.type = "text/javascript";
	script.src = "coverflow.js?user=Guest&pass=";
	
	script.addEventListener("load", function()
	{
		[obj coverFlowDidLoad:Coverflow];
	}, YES);	
	
	document.getElementsByTagName("head")[0].appendChild(script);
}
