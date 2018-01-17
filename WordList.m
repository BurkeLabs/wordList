//
//  WordList.m
//  wordList
//
//  Created by Michelle Burke on 5/17/17.
//  Copyright © 2017 BurkeLabs. All rights reserved.
//

#import "WordList.h"
#import "WordMO+CoreDataProperties.h"

@interface WordList ()

@property NSMutableArray *words;
@property NSManagedObjectContext *moc;

@end

@implementation WordList

+(WordList*) newWithMoc:(NSManagedObjectContext*)moc {
    return [[self alloc] initWithMoc:moc];
}

-(WordList*) initWithMoc:(NSManagedObjectContext*)moc {
    self.words = [NSMutableArray new];
    self.moc = moc;
    [self load];
    return self;
}

-(void) load {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"word" ascending:NO];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Words"];
    request.sortDescriptors = @[sortDescriptor];
    NSArray *wordMOC = [self.moc executeFetchRequest:request error:nil];

    for (WordMO *wordMO in wordMOC) {
        [self.words addObject:[Word newFromMO:wordMO]];
    }
}

-(void) addWord:(NSString*)wordName {
    Word *word = [Word new];
    word.word = wordName;
    word.type = WT_NONE;
    WordMO* object = [[WordMO alloc] initWithContext:self.moc];
    object.word = wordName;
    object.status = word.type;
    [self.moc save:nil];
    word.mo = object;
    [self.words addObject:word];
}

-(void) removeAtIndex:(NSInteger)index {
    Word* word = [self atIndex:index];
    NSManagedObject *aManagedObject = word.mo;
    NSManagedObjectContext *context = [aManagedObject managedObjectContext];
    [context deleteObject:aManagedObject];
    [context save:nil];

    [self.words removeObjectAtIndex:index];

}

-(NSUInteger) count{
    return [self.words count];
}
-(Word*) atIndex:(NSInteger)index{
    return [self.words objectAtIndex:index];
}
-(void) rotateWordStateAtIndex:(NSInteger)index{
    Word *word = [self atIndex:index];
    word.type = (word.type + 1) % (WT__COUNT);
    WordMO *wordMO = word.mo;
    wordMO.status = word.type;
    [[wordMO managedObjectContext] save:nil];

}

-(void)moveFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    Word *word = [self atIndex:fromIndex];
    [self.words removeObject:word];
    [self.words insertObject:word atIndex:toIndex];
}

@end
