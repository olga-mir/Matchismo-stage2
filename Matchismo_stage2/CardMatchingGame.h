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


/**
 *  Add cards to play. The number of cards added is numOfCardsToMatch. If there are not enough cards left in the deck then there are no cards added and NO is returned.
 *
 *  @return YES - if the cards were edded successfully, NO - if there were not enough cards in the deck
 */
- (BOOL)addCardsToPlay;


/**
 *  Check if the current game can not be continued.
 *
 *  @return YES - the current game is over. NO - the game can be continued
 */
- (BOOL)isTheGameOver;


@end
