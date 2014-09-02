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

// indication whether there are more matches possible with the cards left
@property (nonatomic, readonly) BOOL moreMatchesAvailable;


// designated initializer
- (instancetype)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck cardsInSet:(NSUInteger)numOfCardsToMatch;

// purge the current cards and deal new set
- (void)restartGame;

- (Card *)debugWrapper_choseCardAtIndex:(NSUInteger)index;
- (void)choseCardAtIndex:(NSUInteger)index;
- (Card *)cardAtIndex:(NSUInteger)index;

// return number of cards that are currently in the game (dealt from the deck and not taken away by matches)
- (NSUInteger)curNumberOfCardsInGame;

// Total number of cards in game, including cards "removed" by previous matches.
// It starts with default number of cards provided to initializer on object creation and increases every time
// user requests more cards to add to the current game.
//- (NSUInteger)totalNumberOfCardsInGame;

// add requested number of cards from the deck to the game
// return False if there were not enough cards in the deck.
- (BOOL)addCardsToPlay:(NSUInteger)cardsToAdd;



@end
