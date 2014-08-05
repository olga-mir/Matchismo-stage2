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
#import "Grid.h"
#import "Utils.h"

@interface CardGameViewController ()

@property (strong, nonatomic) CardMatchingGame *game;

// grid of cards currently in game
@property (strong, nonatomic) Grid *grid;

// A general view that specifies the bounds of the cards area
@property (weak, nonatomic) IBOutlet UIView *cardsDisplayArea;
@property (strong, nonatomic) NSMutableArray *cardViews; // of CardView's

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *dealButton;


@end


@implementation CardGameViewController

#pragma mark - Properties
- (CardMatchingGame *)game
{
  if(!_game) _game = [[CardMatchingGame alloc] initWithCardCount:[self defaultNumOfCardsInGame]
                                                       usingDeck:[self createDeck]
                                                      cardsInSet:[self numOfCardsToMatch]];
  
  // The game might still be nil if there were not enough cards in the deck.
  // It wouldn't happen in this implementation, because the number of cards for initial game view
  // is much smaller than the cards in the deck.
  return _game;
}

- (NSMutableArray *)cardViews
{
  if (!_cardViews) _cardViews = [[NSMutableArray alloc] init];
  return _cardViews;
}

- (Grid *)grid
{
  if (!_grid) {
    NSLog(@"Alloc new grid");
    _grid = [[Grid alloc] init];
    
    _grid.size = self.cardsDisplayArea.frame.size;
    _grid.cellAspectRatio = [self getCardAspectRatio];
    _grid.minimumNumberOfCells = [self defaultNumOfCardsInGame];
    
  }
  return _grid;
}


// The card views will not handle user's gestures.
// The gestures will be handled by the game controller since only the view controller
// has the connection between the cards in the game which is held by model and every individual card view
// Other options could be storing the card index at the view, which is bad because it mixes the view with model
// or the view could notify the VC of its value. But that will make it impossible to use
// for a game with two identical decks or for a deck with two or more sets of identical cards in it
- (void)tap:(UITapGestureRecognizer *)tapGesture
{
  NSLog(@"Tap gesture recognizer in main VC");
  
  CGPoint tapLocation = [tapGesture locationInView:self.cardsDisplayArea];
  
  NSUInteger row = tapLocation.y / self.grid.cellSize.height;
  NSUInteger col = tapLocation.x / self.grid.cellSize.width;
  NSUInteger chosenCardIndex = row * self.grid.columnCount + col;
  
  CardView *cardView = [self.cardViews objectAtIndex:chosenCardIndex];
  cardView.faceUp = !cardView.faceUp;
  
  NSLog(@"Chose card at index: %d, card by the VC: %@", chosenCardIndex, cardView);
  [self.game choseCardAtIndex:chosenCardIndex];
  
  [self updateUI];
}

- (void) updateUI
{
/*  for (UIButton *cardButton in self.cardButtons) {
   int cardButtonIndex = [self.cardButtons indexOfObject:cardButton];
   Card *card = [self.game cardAtIndex:cardButtonIndex];
   [cardButton setTitle:[self titleForCard:card] forState:UIControlStateNormal];
   [cardButton setBackgroundImage:[self backgroundImageForCard:card] forState:UIControlStateNormal];
   cardButton.enabled = !card.isMatched;
  }*/
  
  NSLog(@"updateUI. cardViews count is %d", [self.cardViews count]);
  SYSASSERT(([self.cardViews count] == self.game.curNumberOfCardsInGame), @"Params inconsistency");
  for (int i = 0; i < [self.cardViews count]; i++) {
    
    // get a card from the model and its corresponding view
    Card *card = [self.game cardAtIndex:i];
    CardView *cardView = self.cardViews[i];
    
    // Matched cards are not shown
    cardView.hidden = card.isMatched;
    cardView.faceUp = card.isChosen;
  }
  self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
}

#define CARD_VIEW_SCALE_FACTOR 0.97

- (void)viewDidLoad
{
  NSLog(@"CardGameVC: viewDidLoad");
  
  [super viewDidLoad];
  
  [self.cardsDisplayArea setBackgroundColor:[UIColor clearColor]]; // the view has alpha 1 and clearColor, so that the subviews will be visible
  
  // The card views will not handle user's gestures.
  // The gestures will be handled by the game controller since only the view controller
  // has the connection between the cards in the game which is held by model and every individual card view
  // see the tap gesture handler in this VC for more explanation about this implementation decision
  [self.cardsDisplayArea addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
  
  // Update the grid
  self.grid.size = self.cardsDisplayArea.frame.size; // it could change due to rotate
  self.grid.minimumNumberOfCells = self.game.curNumberOfCardsInGame;
  NSLog(@"CardGameVC: self.game.curNumberOfCardsInGame: %d", self.game.curNumberOfCardsInGame);
  NSLog(@"%@", self.grid);
  
  SYSASSERT(self.grid.inputsAreValid, @"Can't layout the views because grid inputs are invalid"); // TODO - temp. do something sensible later
  
  // populate the grid with the card views
  
  for (int cardInd = 0; cardInd < self.game.curNumberOfCardsInGame; cardInd++) {
      
    NSUInteger r = cardInd / self.grid.columnCount;
    NSUInteger c = cardInd % self.grid.columnCount;
    
    CGRect gridCell = [self.grid frameOfCellAtRow:r inColumn:c];
    
    // frames provided by grid take all the available space, so the frame for the card view
    // should be scalled a little in order to provide some spacing between them
    CGRect frame;
    frame.size.width  = gridCell.size.width * CARD_VIEW_SCALE_FACTOR;
    frame.size.height = gridCell.size.height * CARD_VIEW_SCALE_FACTOR;
    
    // Also the frame must be positioned in the center of the grid cell
    frame.origin.x = gridCell.origin.x + (gridCell.size.height - frame.size.height) / 2;
    frame.origin.y = gridCell.origin.y + (gridCell.size.width - frame.size.width) / 2;
          
    Card *card = [self.game cardAtIndex:cardInd];
    CardView *cardView = [self createCardViewWithFrame:frame withCard:card];
    [self.cardViews addObject:cardView];

    [self.cardsDisplayArea addSubview:cardView];
  }
}



#pragma mark - User Interface

// at this stage the deal button doesn't prompt the user if he really intends to drop current game
- (IBAction)touchDealButton:(id)sender
{
  NSLog(@"DEAL - in the main VC");
  [self.game restartGame];
  [self updateUI];
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



#pragma mark - Virtual Methods
// Used throw exception mechanism in order to enforce the abstracness of these methods.
// Use of protocol or compiler warnings like __attribute__((unavailable(msg)))
// will result in compile time error (which is good),
// but will prevent from calling these functions in this base class.
// Since this "error" must be handled and fixed in development stage
// it is appropriate here to use an assertion or throw an exception.
// The exception is preferrable though, because in this case there is
// no need in return statement that would be more of a workaround
- (Deck *)createDeck
{
  mustOverride();
}

- (NSUInteger)numOfCardsToMatch
{
  mustOverride();
}

- (NSUInteger)defaultNumOfCardsInGame
{
  mustOverride();
}

- (CardView *)createCardViewWithFrame:(CGRect)frame withCard:(Card *)card
{
  mustOverride();
}

- (CGFloat)getCardAspectRatio
{
  mustOverride();
}

@end


