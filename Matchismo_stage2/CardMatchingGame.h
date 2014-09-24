//
//  CardMatchingGame.h
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//
#import <Foundation/Foundation.h>

@class Card;
@class Deck;

@interface CardMatchingGame : NSObject

// Current game score
@property (nonatomic, readonly) NSInteger score;

// designated initializer
- (instancetype)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck cardsInSet:(NSUInteger)numOfCardsToMatch;

// purge the current cards and deal new set
- (void)restartGame;

- (Card *)debugWrapper_choseCardAtIndex:(NSUInteger)index;
- (void)choseCardAtIndex:(NSUInteger)index;
- (Card *)cardAtIndex:(NSUInteger)index;

// return number of cards that are currently in the game (dealt from the deck and not taken away by matches)
- (NSUInteger)curNumberOfCardsInGame;


// add requested number of cards from the deck to the game
// return False if there were not enough cards in the deck.
- (BOOL)addCardsToPlay:(NSUInteger)cardsToAdd;


/**
 *  Return indication if there are matches available with the cards that are currently in the game. If there are no matches in the game the property aRandomMatch will be empty array, otherwise it will always hold a set of cards that matches
 *
 *  @return YES if there are matches available and NO if there are no matches
 */
- (BOOL)moreMatchesAvailable;


@end
