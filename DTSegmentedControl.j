@import <Foundation/CPURLRequest.j>
@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>

@implementation ViewWindowView : CPView
{
    CPButton listViewButton;
    CPButton artistsViewButton;
    CPButton coverflowViewButton;
}

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];
    listViewButton = [aCoder decodeObjectForKey:@"listViewButton"];
    artistsViewButton = [aCoder decodeObjectForKey:@"artistsViewButton"];
    coverflowViewButton = [aCoder decodeObjectForKey:@"coverflowViewButton"];
    [self addSubview:listViewButton];
    [self addSubview: artistsViewButton];
    [self addSubview: coverflowViewButton];
    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];
        
   [aCoder encodeObject:listViewButton forKey:@"listViewButton"];
   [aCoder encodeObject:artistsViewButton forKey:@"artistsViewButton"];
   [aCoder encodeObject:coverflowViewButton forKey:@"coverflowViewButton"];
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    
    //viewControl = [[DTSegmentedControl alloc] initWithFrame: CPRectCreateCopy(aFrame)];
    //[self addSubview: viewControl];
    
    listViewButton = [[CPButton alloc] initWithFrame: CPRectMake(0,CGRectGetHeight(aFrame)/2.0 - 8,26,CPRectGetHeight(aFrame))];
    [listViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewListSelected.tif?user=Guest&pass=" size:CPSizeMake(26, 21)]];
    [listViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewListSelected.tif?user=Guest&pass=" size:CPSizeMake(26, 21)]];
    [listViewButton setBordered:NO];
    [listViewButton setTarget:self];
    [listViewButton setAction:nil];
    [self addSubview: listViewButton];
    
    artistsViewButton = [[CPButton alloc] initWithFrame: CPRectMake(26,CGRectGetHeight(aFrame)/2.0 - 8,25,CPRectGetHeight(aFrame))];
    [artistsViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewArtistEnabled.tiff?user=Guest&pass=" size:CPSizeMake(25, 21)]];
    [artistsViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewArtistSelectedPressed.tif?user=Guest&pass=" size:CPSizeMake(25, 21)]];
    [artistsViewButton setBordered:NO];
    [artistsViewButton setTarget:self];
    [artistsViewButton setAction:@selector(click:)];
    [self addSubview: artistsViewButton];
    
    coverflowViewButton = [[CPButton alloc] initWithFrame: CPRectMake(51,CGRectGetHeight(aFrame)/2.0 - 8,27,CPRectGetHeight(aFrame))];
    [coverflowViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewCoverflowEnabled.tif?user=Guest&pass=" size:CPSizeMake(27, 21)]];
    [coverflowViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewCoverflowPressed.tif?user=Guest&pass=" size:CPSizeMake(27, 21)]];
    [coverflowViewButton setBordered:NO];
    [coverflowViewButton setTarget:self];
    [coverflowViewButton setAction:@selector(click:)];
    [self addSubview: coverflowViewButton];
    
    return self;
}

-(void)click:(id)sender
{
    if(sender == listViewButton)
    {
        [listViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewListSelected.tif?user=Guest&pass=" size:CPSizeMake(26, 21)]];
        [listViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewListSelected.tif?user=Guest&pass=" size:CPSizeMake(26, 21)]];
        [listViewButton setAction:nil];
        [[CPNotificationCenter defaultCenter] postNotificationName:"ChangeView" object:self userInfo:[CPDictionary dictionaryWithObject:"List" forKey:"View"]];
        
        [artistsViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewArtistEnabled.tiff?user=Guest&pass=" size:CPSizeMake(25, 21)]];
        [artistsViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewArtistPressed.tif?user=Guest&pass=" size:CPSizeMake(25, 21)]];
        [artistsViewButton setAction:@selector(click:)];
        [coverflowViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewCoverflowEnabled.tif?user=Guest&pass=" size:CPSizeMake(27, 21)]];
        [coverflowViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewCoverflowPressed.tif?user=Guest&pass=" size:CPSizeMake(27, 21)]];
        [coverflowViewButton setAction:@selector(click:)];
    }
    if(sender == artistsViewButton)
    {
        [artistsViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewArtistSelected.tif?user=Guest&pass=" size:CPSizeMake(25, 21)]];
        [artistsViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewArtistSelected.tif?user=Guest&pass=" size:CPSizeMake(25, 21)]];
        [artistsViewButton setAction:nil];
        [[CPNotificationCenter defaultCenter] postNotificationName:"ChangeView" object:self userInfo:[CPDictionary dictionaryWithObject:"Artists" forKey:"View"]];
        
        [listViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewListEnabled.tif?user=Guest&pass=" size:CPSizeMake(26, 21)]];
        [listViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewListPressed.tif?user=Guest&pass=" size:CPSizeMake(26, 21)]];
        [listViewButton setAction:@selector(click:)];
        [coverflowViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewCoverflowEnabled.tif?user=Guest&pass=" size:CPSizeMake(27, 21)]];
        [coverflowViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewCoverflowPressed.tif?user=Guest&pass=" size:CPSizeMake(27, 21)]];
        [coverflowViewButton setAction:@selector(click:)];
    }
    if(sender == coverflowViewButton)
    {
        [coverflowViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewCoverFlowSelected.tif?user=Guest&pass=" size:CPSizeMake(27, 21)]];
        [coverflowViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewCoverFlowSelected.tif?user=Guest&pass=" size:CPSizeMake(27, 21)]];
        [coverflowViewButton setAction:nil];
        [[CPNotificationCenter defaultCenter] postNotificationName:"ChangeView" object:self userInfo:[CPDictionary dictionaryWithObject:"Coverflow" forKey:"View"]];
        
        [listViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewListEnabled.tif?user=Guest&pass=" size:CPSizeMake(26, 21)]];
        [listViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewListPressed.tif?user=Guest&pass=" size:CPSizeMake(26, 21)]];
        [listViewButton setAction:@selector(click:)];
        [artistsViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewArtistEnabled.tiff?user=Guest&pass=" size:CPSizeMake(25, 21)]];
        [artistsViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewArtistPressed.tif?user=Guest&pass=" size:CPSizeMake(25, 21)]];
        [artistsViewButton setAction:@selector(click:)];
    }       
}

-(void)setSegmentWithName:(CPString)aName
{
    if(aName == "List")
    {
        [listViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewListSelected.tif?user=Guest&pass=" size:CPSizeMake(26, 21)]];
        [listViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewListSelected.tif?user=Guest&pass=" size:CPSizeMake(26, 21)]];
        [listViewButton setAction:nil];
        [[CPNotificationCenter defaultCenter] postNotificationName:"ChangeView" object:self userInfo:[CPDictionary dictionaryWithObject:"List" forKey:"View"]];
        
        [artistsViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewArtistEnabled.tiff?user=Guest&pass=" size:CPSizeMake(25, 21)]];
        [artistsViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewArtistPressed.tif?user=Guest&pass=" size:CPSizeMake(25, 21)]];
        [artistsViewButton setAction:@selector(click:)];
        [coverflowViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewCoverflowEnabled.tif?user=Guest&pass=" size:CPSizeMake(27, 21)]];
        [coverflowViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewCoverflowPressed.tif?user=Guest&pass=" size:CPSizeMake(27, 21)]];
        [coverflowViewButton setAction:@selector(click:)];
    }
    if(aName == "Artists")
    {
        [artistsViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewArtistSelected.tif?user=Guest&pass=" size:CPSizeMake(25, 21)]];
        [artistsViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewArtistSelected.tif?user=Guest&pass=" size:CPSizeMake(25, 21)]];
        [artistsViewButton setAction:nil];
        [[CPNotificationCenter defaultCenter] postNotificationName:"ChangeView" object:self userInfo:[CPDictionary dictionaryWithObject:"Artists" forKey:"View"]];
        
        [listViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewListEnabled.tif?user=Guest&pass=" size:CPSizeMake(26, 21)]];
        [listViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewListPressed.tif?user=Guest&pass=" size:CPSizeMake(26, 21)]];
        [listViewButton setAction:@selector(click:)];
        [coverflowViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewCoverflowEnabled.tif?user=Guest&pass=" size:CPSizeMake(27, 21)]];
        [coverflowViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewCoverflowPressed.tif?user=Guest&pass=" size:CPSizeMake(27, 21)]];
        [coverflowViewButton setAction:@selector(click:)];
    }
    if(aName == "Coverflow")
    {
        [coverflowViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewCoverFlowSelected.tif?user=Guest&pass=" size:CPSizeMake(27, 21)]];
        [coverflowViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewCoverFlowSelected.tif?user=Guest&pass=" size:CPSizeMake(27, 21)]];
        [coverflowViewButton setAction:nil];
        [[CPNotificationCenter defaultCenter] postNotificationName:"ChangeView" object:self userInfo:[CPDictionary dictionaryWithObject:"Coverflow" forKey:"View"]];
        
        [listViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewListEnabled.tif?user=Guest&pass=" size:CPSizeMake(26, 21)]];
        [listViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewListPressed.tif?user=Guest&pass=" size:CPSizeMake(26, 21)]];
        [listViewButton setAction:@selector(click:)];
        [artistsViewButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewArtistEnabled.tiff?user=Guest&pass=" size:CPSizeMake(25, 21)]];
        [artistsViewButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:"Resources/viewArtistPressed.tif?user=Guest&pass=" size:CPSizeMake(25, 21)]];
        [artistsViewButton setAction:@selector(click:)];
    }       
}


@end 
