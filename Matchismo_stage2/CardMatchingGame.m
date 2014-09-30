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
#import "Utils.h"


@interface CardMatchingGame()

/////// PUBLIC INTERFACE

// Current game score
@property (nonatomic, readwrite) NSInteger score;

/////// PRIVATE INTERFACE

// the card game mode - match 2 or 3 cards at a time.
@property (nonatomic) NSUInteger numOfCardsToMatch;

// Cards that are currently dealt
@property (nonatomic, strong) NSMutableArray *cards; // of Cards

// Deck of cards for current game. As the game goes, cards are being drawn from it.
@property (strong, nonatomic)Deck *deck;

// Deck of cards to save for game reset purposes
@property (strong, nonatomic)Deck *savedDeck;

// How many cards to start the game with. Once the game is initialized all the following games instances will start with the same number of cards
@property (nonatomic)NSUInteger initialNumberOfCards;

// One of the possible matches with the cards that are currently in play
@property (nonatomic, strong) NSMutableSet *aRandomMatch;

@end


@implementation CardMatchingGame


#pragma mark - Properties

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

- (Deck *)savedDeck
{
  if(!_savedDeck) _savedDeck = [[Deck alloc] init];  // this 'if' will never be true in this game implementation
  return _savedDeck;
}

- (NSMutableSet *)aRandomMatch
{
  if (!_aRandomMatch) _aRandomMatch = [[NSMutableSet alloc] init];
  return _aRandomMatch;
}


/**
 *  Designated initializer
 *
 *  @param count             initial number of cards to start the game
 *  @param deck              deck of cards for the game
 *  @param numOfCardsToMatch how many cards should be attemted for a match
 *
 *  @return initialized object
 */
- (instancetype)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck cardsInSet:(NSUInteger)numOfCardsToMatch
{
  self = [super init];
  
  if (self) {
    if ([deck remainingCards] >= count) {
      
      _deck = deck;
      _numOfCardsToMatch = numOfCardsToMatch;
      _initialNumberOfCards = count;
      _savedDeck = [deck copy];
 
      [self dealCards:count];
      _aRandomMatch = [self findRandomMatch];
    } else {
      self = nil;
      
      // In this implementation this situation will never happen. But assertion will help to catch this case if someone add another game later.
      SYSASSERT(NO, ([NSString stringWithFormat:@"There is not enough cards in the deck to initialize game with requested count. Cards in deck: %lu, requested number of cards: %lu", (unsigned long)[deck remainingCards], (unsigned long)count]));
    }
  }
  return self;
}


/**
 *  Deal cards from the deck. The number of cards dealt by this function is the minimum between the requested amount and amount available in the deck
 *
 *  @param count required amount of cards to deal.
 */
- (void)dealCards:(NSUInteger)count
{
  for (int i = 0; i < count ; i++) {
    Card *card = [self.deck drawRandomCard];
    if (card) {
      SYSASSERT(!card.isMatched, @"Card just drawn from the deck cannot be matched");
      SYSASSERT(!card.isChosen,  @"Card just drawn from the deck cannot be chosen");
      
      [self.cards addObject:card];
    }
  }
}


/**
 *  Reset the game with the same configuration
 */
- (void)restartGame
{
  NSLog(@"Restart game");
  [self.cards removeAllObjects];
  self.deck = [self.savedDeck copy];
  [self dealCards:self.initialNumberOfCards];
  self.aRandomMatch = [self findRandomMatch];
  self.score = 0;
}


/**
 *  Get a card at the given index. It might not be neceserraly a card that can be played, i.e. it can hold YES for the 'isMatched' property. It is the implementation decision to keep matched cards in the 'cards' array, but not show them to the user.
 *
 *  @param index index of the card in 'cards' array
 *
 *  @return Card from that index or nil if the index is out of bounds
 */
- (Card *)cardAtIndex:(NSUInteger)index
{
  return (index < [self.cards count]) ? self.cards[index] : nil;
}


/**
 *  Number of cards currently visible and availbale to pay with. In model these are the cards in the 'cards' array with 'isMatched' property set to NO
 *
 *  @return visible cards that are available to play
 */
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


/**
 *  Add more cards to the current game. If the specified amount of cards could not be added then no cardss are added to the game. That means that either numOfCardsToAdd or 0 cards had been added to the game.
 *
 *  @param numOfCardsToAdd number of cards to be added
 *
 *  @return YES if the requested number of cards was successfully added, NO - otherwise, e.g. when the deck was deplected.
 */
- (BOOL)addCardsToPlay:(NSUInteger)numOfCardsToAdd
{
  NSLog(@"Adding %lu more cards to game", (unsigned long)numOfCardsToAdd);
  
  if (numOfCardsToAdd > [self.deck remainingCards]) {
    return NO; // implementation decision - if there are not enough cards in the deck then don't add any cards at all
  }
  
  for (NSUInteger i = 0; i < numOfCardsToAdd; i++) {
    [self.cards addObject:[self.deck drawRandomCard]];
  }
  
  // As a result of new card added there could be new matches.
  // Note, that sometimes (like in Set) game even though there is no matches available, the game is not over.
  if (![self.aRandomMatch count]) {
    self.aRandomMatch = [self findRandomMatch];
  }
  return YES;
}


# pragma mark - Matching Logic

static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int COST_TO_CHOSE = 1;

// different form regular func is that it returns Card, that can be inspected
- (Card *)debugWrapper_choseCardAtIndex:(NSUInteger)index;
{
  Card *card = [self cardAtIndex:index];
  [self choseCardAtIndex:index];
  return card;
}

/**
 *  Chose card at given index. It will look for other chosen cards and will try to match them if there is at least total of 'numOfCardsToMatch' chosen cards. If the chosen cards form a match then a positive score is returned, otherwise zero or negative.
 *
 *  @param index index of the card in the game that is currently chosen
 */
- (void)choseCardAtIndex:(NSUInteger)index
{
  Card *card = [self cardAtIndex:index];
  int scoreForCurrentMatch = 0;
  
   NSLog(@"CardMatchingGame: choseCardAtIndex: %lu, %@", (unsigned long)index, card);
  
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
          
          // Hoooray! The cards matched. The matched cards now should be marked as matched and we also need to check
          // if this match has used (one or more) cards from aRandomMatch. In that case current aRandomMatch is not valid
          // and we should try to find another match if it exists.
          // This is more time and space efficient than keeping all the possible matches OR checking for a possible match after every successful match
          if (matchScore) {
            scoreForCurrentMatch = matchScore * MATCH_BONUS;
            for (Card *c in cardsToMatch) {
              c.matched = YES;
            }
            card.matched = YES;
            
            // now check if it is our aRandomMatch.
            NSMutableSet *justMarried = [[NSMutableSet alloc] initWithArray:cardsToMatch];
            [justMarried addObject:card];
            
            for (Card *c in justMarried) {
              if ([self.aRandomMatch containsObject:c]) {
                NSLog(@"RANDOM_MATCH: JustMarried invalidates aRandomMatch. Try to find another randomMatch");
                [self.aRandomMatch removeAllObjects];
                self.aRandomMatch = [self findRandomMatch];
                NSLog(@"RANDOM_MATCH: aRandomMatch count = %lu", (unsigned long)[self.aRandomMatch count]);
                break;
              }
            }

            
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


/**
 *  With the cards that are currently in the game, find a set of cards that is a match according to the specific game logic
 *
 *  @return array of cards that form a match
 */
- (NSMutableSet *)findRandomMatch
{
  NSLog(@"RANDOM_MATCH: Checking for a match");
  NSMutableSet *aMatch = [[NSMutableSet alloc] init];
  NSMutableArray *remainingCards = [[NSMutableArray alloc] init];
  
  // First, find all the cards that are currently in the game.
  // These are the cards with isMatched = NO
  for (Card *card in self.cards) {
    if (!card.isMatched) {
      [remainingCards addObject:card];
    }
  }
  
  // set up combinations of a 'card' and 'otherCards' to match this card against
  Card *firstCard;
  NSMutableArray *otherCards = [[NSMutableArray alloc] init];
  
  for (int i = 0; i < [remainingCards count]; i++) {
    
    firstCard = remainingCards[i]; // in the following loop(s) will set other cards to try match against this one
    
    for (int j = i + 1; j < [remainingCards count]; j++) {
      
      [otherCards removeAllObjects];
      [otherCards addObject:remainingCards[j]];
      
      // Although in the perfect world this model should support N cards matching mode, in the reality,
      // the simplicity of code and reduction of run-time computation and memory justifies introducing the assumption that
      // this model only supports 2 or 3 cards matching
      NSLog(@"numOfCardsToMatch: %lu", (unsigned long)self.numOfCardsToMatch);
      
      if (self.numOfCardsToMatch == 3) {
        for (int k = j + 1; k < [remainingCards count]; k++) {
          NSLog(@"Add 3rd card");
          [otherCards addObject:remainingCards[k]];

          // now we have a set of cards, try to match them
          int score = [firstCard match:otherCards];
          if (score > 0) { // a match has been found
            [aMatch addObject:firstCard];
            [aMatch addObjectsFromArray:otherCards];
            NSLog(@"RANDOM_MATCH: Match has been found");
            for (Card *c in aMatch) {
              NSLog(@"%@,", c);
            }
            return aMatch;
          }
          [otherCards removeLastObject];
        } // end for k..
      } else {
        NSLog(@"[otherCards count] = %lu", (unsigned long)[otherCards count]);
        
        // now we have a set of cards, try to match them
        int score = [firstCard match:otherCards];
        if (score > 0) { // a match has been found
          [aMatch addObject:firstCard];
          [aMatch addObjectsFromArray:otherCards];
          NSLog(@"RANDOM_MATCH: Match has been found");
          for (Card *c in aMatch) {
            NSLog(@"%@,", c);
          }
          return aMatch;
        }
      }
    } // end for j..
  } // end for i..
  
  return aMatch;
}


/**
 *  Return indication if there are matches available with the cards that are currently in the game. If there are no matches in the game the property aRandomMatch will be empty array, otherwise it will always hold a set of cards that matches
 *
 *  @return YES if there are matches available and NO if there are no matches
 */
- (BOOL)moreMatchesAvailable
{
  return [self.aRandomMatch count];
}


@end

