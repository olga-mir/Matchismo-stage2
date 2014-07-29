//
//  cardGameViewController.m
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "CardGameViewController.h"
#import "CardMatchingGame.h"
#import "CardView.h"

@interface CardGameViewController ()

@property (strong, nonatomic) CardMatchingGame *game;

//@property (strong, nonatomic) NSMutableArray *cards; // of Card's (models)

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *dealButton;


@end


@implementation CardGameViewController

- (instancetype)init
{
  NSLog(@"CardGameViewController: init");
  self = [super init];
  if (self) {
  }
  return self;
}


- (CardMatchingGame *)game {
  if(!_game) _game = [[CardMatchingGame alloc] initWithCardCount:[self defaultNumOfCardsInGame]
                                                       usingDeck:[self createDeck]
                                                      cardsInSet:[self numOfCardsToMatch]];
  
  // The game might still be nil if there were not enough cards in the deck.
  // It wouldn't happen in this implementation, because the number of cards for initial game view
  // is much smaller than the cards in the deck.
  return _game;
}

#pragma mark - Outlets

// at this stage the deal button doesn't prompt the user if he really intends to drop current game
- (IBAction)touchDealButton:(id)sender
{
  NSLog(@"DEAL - in the main VC");
  [self.game restartGame];
  [self updateUI];
}


- (IBAction)swipe:(UISwipeGestureRecognizer *)sender {
  
//  int chosenCardIndex = [self.cardsViews indexOfObject:sender];
  int chosenCardIndex = [self.view.subviews indexOfObject:sender];
  
//  CardView *cardView = [self.cardsViews objectAtIndex:chosenCardIndex];
  CardView *cardView = [self.view.subviews objectAtIndex:chosenCardIndex];
  cardView.faceUp = !cardView.faceUp;
  
  NSLog(@"Chose card at index: %d", chosenCardIndex);
  [self.game choseCardAtIndex:chosenCardIndex];
}


/*
- (IBAction)touchCardButton:(id)sender
{
  NSLog(@"Touch card button");
  int chosenCardButtonIndex = [self.cardButtons indexOfObject:sender];
  NSLog(@"Chose card at index: %d", chosenCardButtonIndex);
  [self.game choseCardAtIndex:chosenCardButtonIndex];
  [self updateUI];
}
*/

- (void) updateUI
{/*
  for (UIButton *cardButton in self.cardButtons) {
    int cardButtonIndex = [self.cardButtons indexOfObject:cardButton];
    Card *card = [self.game cardAtIndex:cardButtonIndex];
    [cardButton setTitle:[self titleForCard:card] forState:UIControlStateNormal];
    [cardButton setBackgroundImage:[self backgroundImageForCard:card] forState:UIControlStateNormal];
    cardButton.enabled = !card.isMatched;
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];

  }*/
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

- (void)viewDidLoad
{
  NSLog(@"CardGameVC: viewDidLoad");
  
  [super viewDidLoad];
  
  for (int c = 0; c < self.game.curNumberOfCardsInGame; c++) {
   
    CardView *cardView = [self createCardViewWithCard:[self.game cardAtIndex:c]];

//    [cardView addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:cardView action:@selector(swipe:)]];
    
    [self.view addSubview:cardView];
  }
}


#pragma mark - Abstract Methods
// TODO - raise exeptions in these methods / other proper abstract class techniques?

// createDeck method is an abstract method.
// the VCs who inherit from it will create their own decks depending on their type
- (Deck *)createDeck
{
  NSLog(@"Abstract method %@ must be implemented in a subclass", NSStringFromSelector(_cmd));
  return nil;
}

- (NSUInteger)numOfCardsToMatch
{
  NSLog(@"Abstract method %@ must be implemented in a subclass", NSStringFromSelector(_cmd));
  return 0;
}

- (NSUInteger)defaultNumOfCardsInGame
{
  NSLog(@"Abstract method %@ must be implemented in a subclass", NSStringFromSelector(_cmd));
  return 0;
}

- (CardView *)createCardViewWithCard:(Card *)card
{
  NSLog(@"Abstract method %@ must be implemented in a subclass", NSStringFromSelector(_cmd));
  return nil;
}


@end

