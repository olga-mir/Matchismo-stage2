//
//  CardMatchingGame.m
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//


#import "CardMatchingGame.h"
#import "Card.h"
#import "Deck.h"


@interface CardMatchingGame()

/////// PUBLIC INTERFACE

// Current game score
@property (nonatomic, readwrite) NSInteger score;

// indication whether there are more matches possible with the cards left
@property (nonatomic, readwrite) BOOL moreMatchesAvailable;

/////// PRIVATE INTERFACE

// the card game mode - match 2 or 3 cards at a time.
@property (nonatomic) NSUInteger numOfCardsToMatch;

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
  self.moreMatchesAvailable = YES;
  NSLog(@"CardMatchingGame.m: initWithCardCount completed");
  return self;
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


// reset the game logic. The number of cards is defined only once in the beggining of the game
// i.e. it is set once in the CardMatchingGame initializer
- (void)restartGame // TODO - init functionality with the init.
{
  int cardsInGame = [self.cards count];
  [self.cards removeAllObjects];
  [self dealCards:cardsInGame];
  self.score = 0;
  self.moreMatchesAvailable = YES;
}

// Getter for a card at specified index
- (Card *)cardAtIndex:(NSUInteger)index
{
  return (index < [self.cards count]) ? self.cards[index] : nil;
}

// return number of cards that are currently in the game (dealt from the deck and not taken away by matches)
- (NSUInteger)curNumberOfCardsInGame
{
  NSUInteger count = 0;
  for (Card *card in self.cards) {
    if (!card.isMatched) {
      count++;
    }
  }
  return count;
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
  
  NSLog(@"Game model: chose card: %@", card);
  
  if (card.isChosen) {
    // if the card was already chosen, then toggle it back to unchosen state.
    card.chosen = NO;
    
  } else {
    
    // these are all the cards that are to be match against the current card (which is [self cardAtIndex:index])
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
            
            // If in the current round the cards were matched then we should check if there
            // are more matches among the remaining cards
            [self searchAvailableMatches];
            
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

//////// THIS IS A BAD BAD BAD CODE
// will replace later
//
// find if there are more matches availble with the cards left
// (current implementation checks hardcoded for the type of Playing card game in the mode of 2 cards to match. - must be replace with generic code
- (void)searchAvailableMatches
{
  
  // Search among all the remaining cards (cards that isMatched == NO)
  // try all possible connections to see if there is a match
  
  // create a temp array of the cards that had not yet been matched
  NSMutableArray *cardsLeft = [[NSMutableArray alloc] init];
  for (Card *card in self.cards) {
    if (!card.isMatched) [cardsLeft addObject:card];
  }
  
  if ([cardsLeft count] > 4) { // more than 4 - there is definitely match, the value of self.moreMatchesAvailable unchanged
    return;
  }
  if ([cardsLeft count] == 0) {
    self.moreMatchesAvailable = NO;
    return;
  }
  
  BOOL moreMatchesAvailable = NO;
  
  if ([cardsLeft count] == 2) { // if only two left - try to match them
    Card *card = cardsLeft[0];
    NSArray *otherCards = [[NSArray alloc] initWithObjects:cardsLeft[1], nil];
    if ([card match:otherCards]) {
      moreMatchesAvailable = YES;
    }
  } else {  // then 4 left
  
    // otherwise there are 4 cards left - try to find a match among them
    NSArray *sets = [[NSArray alloc] initWithObjects:@[@0,@1], @[@0, @2], @[@0,@3], @[@1,@2], @[@2, @3], @[@2,@3],nil];
  
    for (int i = 0; i < [sets count]; i++) {
      NSArray *indexes = sets[i];
    
      Card *card = [cardsLeft objectAtIndex:[indexes[0] integerValue]];
      NSArray *otherCards = [[NSArray alloc] initWithObjects:[cardsLeft objectAtIndex:[indexes[1] integerValue]],
                                                           nil];
      if ([card match:otherCards]) {
        moreMatchesAvailable = YES;
        break;
      }
    }
  }
  
  NSLog(@"PREV: %d, NEXT: %d", self.moreMatchesAvailable, moreMatchesAvailable);
  self.moreMatchesAvailable = moreMatchesAvailable;
  
  return;
}


// recursive function to choose R objects from N.
// Return array will contain all the possible sets
// num of sets is calculated by this formula:
//                    n!
// (n choose r) = ----------
//                r! * (n-r)!
- (NSArray *)choseFromRObjects:(NSUInteger)r NObjects:(NSUInteger)n
{
  return nil;
}


@end

