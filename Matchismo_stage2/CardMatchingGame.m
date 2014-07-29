//
//  CardMatchingGame.m
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//


#import "CardMatchingGame.h"


@interface CardMatchingGame()

// the card game mode - match 2 or 3 cards at a time.
@property (nonatomic) NSUInteger numOfCardsToMatch;

@property (nonatomic, readwrite) NSInteger score;

// Cards that are currently dealt
@property (nonatomic, strong) NSMutableArray *cards; // of Cards

// Deck of cards for current game. As the game goes, cards are being drawn from it.
@property (strong, nonatomic)Deck *deck;

@end


@implementation CardMatchingGame

- (NSMutableArray *)cards
{
  if (!_cards) _cards = [[NSMutableArray alloc] init];
  return _cards;
}

- (Deck *)deck
{
  if(!_deck) _deck = [[Deck alloc] init];  // this 'if' will never be true in this game implementation
  return _deck;
}


// auxilary function used to fill the _cards array from the given deck
// used in initializer and re-deal operation.
- (BOOL)dealCards:(NSUInteger)count
{
  for (int i = 0; i < count ; i++) {
    Card *card = [self.deck drawRandomCard];
    if (card) {
      [self.cards addObject:card];
    } else { // there was not enough cards in the deck
      return NO;
    }
  }
  return YES; // successfully dealt the cards
}

// The class designated inittializer.
// The object recieves its deck from outside, so it can remain general Game Matching logic
// and not depend on the type of cards in the deck
- (instancetype)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck cardsInSet:(NSUInteger)numOfCardsToMatch
{
  NSLog(@"CardMatchingGame.m: initWithCardCount %d", count);
  
  self = [super init];
  
  if (self) {
    self.deck = deck;
    if (![self dealCards:count]) {
      // there was not enough cards, so the deal failed
      self = nil; // TODO - exception?
    } else {
      self.numOfCardsToMatch = numOfCardsToMatch;
    }
  }
  NSLog(@"CardMatchingGame.m: initWithCardCount completed");
  return self;
}

// reset the game logic. The number of cards is defined only once in the beggining of the game
// i.e. it is set once in the CardMatchingGame initializer
- (void)restartGame
{
  int cardsInGame = [self.cards count];
  [self.cards removeAllObjects];
  [self dealCards:cardsInGame];
  self.score = 0;
}

// Getter for a card at specified index
- (Card *)cardAtIndex:(NSUInteger)index
{
  return (index < [self.cards count]) ? self.cards[index] : nil;
}

// return number of cards that are currently in the game (dealt from the deck and not taken away by matches)
- (NSUInteger)curNumberOfCardsInGame
{
  return [self.cards count];
}

// add requested number of cards from the deck to the game
// return False if there were not enough cards in the deck.
- (BOOL)addCardsToPlay:(NSUInteger)numOfCardsToAdd
{
  NSLog(@"Adding cards to game");
  Card *card = [self.deck drawRandomCard];
  NSUInteger cardsAdded = 0;
  
  while (card && (cardsAdded < numOfCardsToAdd)) {
    [self.cards addObject:card];
    cardsAdded++;
    NSLog(@"Added a card");
  }
  
  // if the loop ended because there were not enough card to deal, then return False to the caller
  if (cardsAdded < numOfCardsToAdd) {
    return NO;
  }
  return YES;
}

# pragma mark - Matching Logic

static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int COST_TO_CHOSE = 1;

- (void)choseCardAtIndex:(NSUInteger)index
{
  NSLog(@"CardMatchingGame.h: choseCardAtIndex");
  Card *card = [self cardAtIndex:index];
  int scoreForCurrentMatch = 0;
  
  if (card.isChosen) {
    // if the card was already chosen, then toggle it back to unchosen state.
    // if the user clicked on a card that was previously chosen (face up), this
    // card now should flip over to face down, unchosen state
    card.chosen = NO;
    
  } else {
    
    // these are all the cards that are to be match against the current card (self)
    // i.e in 2 card mode this array will have only one card, in 3 cards mode - 2 cards, etc.
    NSMutableArray *cardsToMatch = [[NSMutableArray alloc] init];
    
    // first we need to find all the cards that are face up,
    // but has not yet been withdrawn from game by being matched to other cards.
    for (Card *otherCard in self.cards) {
      if (otherCard.isChosen && !otherCard.isMatched) {
        
        [cardsToMatch addObject:otherCard];
        
        // only when exact number of cards to current game mode is chosen we can match them
        if ([cardsToMatch count] + 1 == self.numOfCardsToMatch) {
          
          int matchScore = [card match:cardsToMatch];
          
          if (matchScore) {
            scoreForCurrentMatch = matchScore * MATCH_BONUS;
            for (Card *c in cardsToMatch) {
              c.matched = YES;
            }
            card.matched = YES;
            
          } else { // the cards didn't match in any way - return them all to the game.
            
            scoreForCurrentMatch = -MISMATCH_PENALTY;
            for (Card *c in cardsToMatch) {
              c.chosen = NO;
            }
          }
          self.score += scoreForCurrentMatch;
        }
      }
    }
    self.score -= COST_TO_CHOSE;
    card.chosen = YES;
    
  }
}

@end

