@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>

@implementation CPURLVariables : CPObject
{
    CPDictionary urlVariables;
}

+(void)initialize
{
    urlVariables = [CPDictionary dictionary];
    var searchString = document.location.search;

    // strip off the leading '?'
    searchString = searchString.substring(1);

    var nvPairs = searchString.split("&");

    for (i = 0; i < nvPairs.length; i++)
    {
        var nvPair = nvPairs[i].split("=");
        var name = nvPair[0];
        var value = nvPair[1];
        [urlVariables setObject:value forKey:name];
    }

}

+(id)valueForName:(CPString)aName, ...
{
    var values = new Array();
	for (var i = 2; i < arguments.length; i++) {
		var value = arguments[i];
		values.push([urlVariables objectForKey:value]);
	}
	if(values.count > 0)
	   return values;
    else
        return urlVaraibles;
    //return [urlVariables objectForKey:aName];
}

+(CPDictionary)all
{
    return urlVaraibles;
}    

function getURLVariables() {//input names to look for or get the whole list
    var urlVariables = [CPDictionary dictionary];
    var searchString = document.location.search;

    // strip off the leading '?'
    searchString = searchString.substring(1);

    var nvPairs = searchString.split("&");

    if(nvPairs.count == 0) return;

    for (i = 0; i < nvPairs.length; i++)
    {
        var nvPair = nvPairs[i].split("=");
        var name = nvPair[0];
        var value = nvPair[1];
        [urlVariables setObject:value forKey:name];
    }

	var values = new Array();
	for (var i = 0; i < arguments.length; i++) {
		var value = arguments[i];
		values.push([urlVariables objectForKey:value]);
	}
	if(values.count > 0)
	   return values;
    else
        return urlVaraibles;
}