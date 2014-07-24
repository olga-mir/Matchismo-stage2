//
//  cardGameViewController.m
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "CardGameViewController.h"
#import "CardMatchingGame.h"

@interface CardGameViewController ()

@property (nonatomic, strong) CardMatchingGame *game;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *dealButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end


@implementation CardGameViewController

-(CardMatchingGame *)game {
  if(!_game) _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count]
                                                       usingDeck:[self createDeck]
                                                      cardsInSet:[self numOfCardsToMatch]];
  return _game;
}

// at this stage the deal button doesn't prompt the user if he really intends to drop current game
- (IBAction)touchDealButton:(id)sender
{
  NSLog(@"DEAL - in the main VC");
  [self.game restartGameUsingDeck:[self createDeck]];
  [self updateUI];
}

- (IBAction)touchCardButton:(id)sender
{
  NSLog(@"Touch card button");
  int chosenCardButtonIndex = [self.cardButtons indexOfObject:sender];
  NSLog(@"Chose card at index: %d", chosenCardButtonIndex);
  [self.game choseCardAtIndex:chosenCardButtonIndex];
  [self updateUI];
}

- (void) updateUI
{
  for (UIButton *cardButton in self.cardButtons) {
    int cardButtonIndex = [self.cardButtons indexOfObject:cardButton];
    Card *card = [self.game cardAtIndex:cardButtonIndex];
    [cardButton setTitle:[self titleForCard:card] forState:UIControlStateNormal];
    [cardButton setBackgroundImage:[self backgroundImageForCard:card] forState:UIControlStateNormal];
    cardButton.enabled = !card.isMatched;
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];

  }
}


- (NSString *)titleForCard:(Card *)card
{
  // This is temporary stage function
  return card.isChosen ? @"??" : @"";
}

- (UIImage *)backgroundImageForCard:(Card *)card
{
  return [UIImage imageNamed:card.isChosen ? @"cardfront" : @"cardback"];
}

#pragma mark - Abstract methods
// TODO - raise exeptions in these methods / other proper abstract class techniques?

// createDeck method is an abstract method.
// the VCs who inherit from it will create their own decks depending on their type
-(Deck *)createDeck
{
  NSLog(@"Someone didn't implement the createDeck method!");
  return nil;
}

-(NSUInteger)numOfCardsToMatch {
  NSLog(@"Abstract method called. Must be implemented in a subclass");
  return 0;
}


@end

