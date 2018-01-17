//
//  WordList.h
//  wordList
//
//  Created by Michelle Burke on 5/17/17.
//  Copyright © 2017 BurkeLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Word.h"

@interface WordList : NSObject

//collection of words
+(WordList*)newWithMoc:(NSManagedObjectContext*)moc;

-(void) addWord:(NSString*)word;
-(void) removeAtIndex:(NSInteger)index;
-(NSUInteger) count;
-(Word*) atIndex:(NSInteger)index;
-(void) rotateWordStateAtIndex:(NSInteger)index;
-(void)moveFromIndex:(NSInteger)index toIndex:(NSInteger)index;

@end
