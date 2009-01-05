//
//  DTScrollingTextField.j
//  DTScrollingTextField
//
//  Created by Eli Draizen on 12/29/08.
//  Copyright Metta Media 2008. All rights reserved.
//

@import <Foundation/Foundation.j>
@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>

@implementation DTScrollingTextField : CPTextField
{
    var scrollDiv;
    BOOL go;
    int speed;
    CPTimer recursionTimer;
}

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];
    go = [aCoder decodeBoolForKey:"go"];
    speed = [[aCoder decodeObjectForKey:"speed"] intValue];
    recursionTimer = [aCoder decodeObjectForKey:"timer"];
    scrollDiv = _DOMElement.childNodes[0];
    scrollDiv.style.overflow = "hidden";
    
    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:go forKey:"go"];
    [aCoder encodeObject:[CPNumber numberWithInt:speed] forKey:"speed"];
    [aCoder encodeObject:recursionTimer forKey:"timer"];
}

-(id)initWithFrame:(CGRect)aFrame
{
    console.log("hey");
    self = [super initWithFrame:aFrame];
    go = NO;
    speed = 1; // change scroll speed with this value
    scrollDiv = _DOMElement.childNodes[0];
    scrollDiv.style.overflow = "hidden";
    console.log("yp");
    return self;
}    

/**
 * This is where the scroll action happens.
 * Recursive method until stopped.
 */
- (void)scrollFromBottom
{
    [recursionTimer invalidate];
    
    if(scrollDiv.scrollTop == scrollDiv.scrollHeight-9)
        scrollDiv.scrollTop = 0;
    
    scrollDiv.scrollTop += speed;

    if (go)
    {
        recursionTimer = [CPTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(recursiveTimerDidFire:) userInfo:nil repeats:YES]
        //[recursionTimer fire];
        //[self scrollFromBottom];
        //setTimeout("scrollFromBottom()",50);
    }
    console.log("done");
}

- (void)recursiveTimerDidFire:(CPTimer)aTimer
{
    //[recursionTimer invalidate];
    [self scrollFromBottom];
    //[[self superview] setNeedsDisplay:YES];
}
 
/**
 * Set the stop variable to be true (will stop the marquee at the next pass).
 */
- (void)stop
{
  go = NO;
}
 
/**
 * Set the stop variable to be false and call the marquee function.
 */
- (void)start
{
  go = YES;
  [self scrollFromBottom];
}
