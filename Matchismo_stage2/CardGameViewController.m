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

@interface CardGameViewController () <UIAlertViewDelegate>

// The model game implementing the game logic
@property (strong, nonatomic) CardMatchingGame *game;

// cardViews presenting the cards that are currently in the game
@property (strong, nonatomic) NSMutableArray *cardViews; // of CardView's

// grid of cards currently in game
@property (strong, nonatomic) Grid *grid;

// A container view that specifies the bounds of the cards area
@property (weak, nonatomic) IBOutlet UIView *cardsDisplayArea;

// Score label
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@end



@implementation CardGameViewController
{
  // At every move there will be exactly one card to reveal / select, this is the card that was tapped on
  CardView *g_cardToChose;
  
  // And there will be 0 or more cards to flip back / de-select (if the current move didn't result in match)
  NSMutableArray *g_cardsToDeselect;
  
  // If there was a match the resulted cards must be removed from the game
  NSMutableArray *g_cardsToRemove;
}

#pragma mark - Defines

// Animation durations for possible animations
#define DEFAULT_ANIMATION_DURATION 0.3
#define REARRANGEMENT_ANIMATION_DURATION                    DEFAULT_ANIMATION_DURATION
#define CARD_SELECTION_OR_DESELECTION_ANIMATION_DURATION    0.6
#define CARD_ARRIVAL_ON_DEAL_ANIMATION_DURATION             (DEFAULT_ANIMATION_DURATION/2)

// Defines small scaling of the card view frame relatevely to its grid cell to provide small spacing between the cards
#define CARD_VIEW_SCALE_FACTOR 0.97


#pragma mark - Properties

- (CardMatchingGame *)game
{
  if(!_game) _game = [[CardMatchingGame alloc] initWithCardCount:[self defaultNumOfCardsInGame]
                                                       usingDeck:[self createDeck]
                                                      cardsInSet:[self numOfCardsToMatch]];
  
  // The game might still be nil if there were not enough cards in the deck.
  // It wouldn't happen in this implementation, because the number of cards
  // in the beginning of the game is much smaller than the number of cards in the deck.
  return _game;
}

- (NSMutableArray *)cardViews
{
  if (!_cardViews) _cardViews = [[NSMutableArray alloc] init];
  return _cardViews;
}

- (Grid *)grid
{
  if (!_grid) _grid = [[Grid alloc] init];
  return _grid;
}


#pragma mark - Lifecycle

- (void)viewDidLoad
{
  NSLog(@"CardGameVC: viewDidLoad");
  
  [super viewDidLoad];
  
  // The card views do not handle user's gestures.
  // The gestures are handled by the game controller since only the view controller
  // has the connection between the cards in the game which is held by Model and every individual card view in the View
  // see the tap gesture handler in this VC for more explanation about this implementation decision
  [self.cardsDisplayArea addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
  
  self.cardsDisplayArea.userInteractionEnabled = YES;
  
  // Aspect ratio is constant through out the game. Other grid inputs depend on geometry and number of cards in the game, so the grid is updated in a few more places
  self.grid.cellAspectRatio = [self getCardAspectRatio];
  
  // Auxilary data structures used to process and animate each step in the game
  g_cardsToDeselect = [[NSMutableArray alloc] init];
  g_cardsToRemove   = [[NSMutableArray alloc] init];
}

- (void)viewDidLayoutSubviews
{
  NSLog(@"viewDidLayoutSubviews");
  
  [super viewDidLayoutSubviews];

  // The game will start with cards already dealt from the deck.
  if (![self.cardViews count]) {
    [self createCardViews];
  } else if ([self gridNeedsUpdate]) {
    [self rearrangeCardViewsWithCheckForGameOver:NO];
  } else {
    NSLog(@"Did nothing in viewDidLayoutSubviews");
  }

  self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
}


#pragma mark - Setup and Reset Methods

/**
 *  Reset the whole game both model and controller. Start a new game
 */
- (void) reset
{
  // reset the model
  [self.game restartGame];
  
  // reset the controller
  [self.cardViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [self.cardViews removeAllObjects];
  [self createCardViews]; // this will also reset the grid
  
  self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
}


/**
 *  Create the CardViews - array of Card views. This array holds the maximum value of cards that has ever been in the current game i.e. if the game started with 12 cards and then at some point user requested 3 more cards, then this array will hold 15 UIViews objects no matter how many matches have been discovered since then. Some of these Views will eventually be hidden
 */
- (void)createCardViews
{
  [self rearrangeCardViewsWithCheckForGameOver:NO];
  [self addViewsForCardsFromIndex:0 toIndex:(self.game.curNumberOfCardsInGame - 1) animateWithDelay:0];
}


#pragma mark - UI

/**
 *  Deal new cards. This operation aborts the current game and starts a new one. Alert is provided to the user to confirm his/her intentions
 *
 *  @param sender The button (not used)
 */
- (IBAction)touchDealButton:(id)sender
{
  [[[UIAlertView alloc] initWithTitle:@"Deal Cards"
                              message:@"This action will terminate the current game. Are you sure you want to proceed?"
                             delegate:self
                    cancelButtonTitle:@"Return"
                    otherButtonTitles:@"OK", nil] show];
}

/**
 *  Alert delegate function. There are two alerts in this game: 1) confirm dealing new cards 2) notify user that there are no more matches available
 *
 *  @param alertView   Alert View
 *  @param buttonIndex Index of the button that was pressed
 */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  NSLog(@"AlertView with title: %@, buttonIndex = %d", alertView.title, buttonIndex);
  
  if ([alertView.title isEqualToString:@"Deal Cards"]) {
    if (buttonIndex == 1) { // "OK" button is pressed - go ahead and reset the game
      [self reset];
    }
  } else if ([alertView.title isEqualToString:@"Game Over"]) {
    [self reset];
  }
}

/**
 *  UI outlet to let user request more cards to be added to the current game.
 *
 *  @param sender sender is the button that triggered this handler (not used)
 */
- (IBAction)touchDealMoreCardsButton:(UIButton *)sender
{
  NSUInteger prevNumOfCards = [self.cardViews count];
  
  BOOL cardsAdded = [self.game addCardsToPlay:[self numOfCardsToMatch]];
  
  if (!cardsAdded) { // there was a problem adding more cards to the game
    [[[UIAlertView alloc] initWithTitle:@"Add More Cards"
                               message:@"There is not enough cards left in the deck. No cards were added."
                              delegate:self
                     cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
  } else {
    
    // As a result of adding more cards the grid might have changed and the remaining cards should recalculate their new size and position
    BOOL cardsWereRearranged = [self rearrangeCardViewsWithCheckForGameOver:NO];
    CGFloat animationDelay = cardsWereRearranged ? REARRANGEMENT_ANIMATION_DURATION : 0;
    
    // Now add new card views to the game
    [self addViewsForCardsFromIndex:prevNumOfCards toIndex:[self.cardViews count] + [self numOfCardsToMatch] - 1 animateWithDelay:animationDelay];
  }
}


/**
 *  Tap gesture recogniser. The gestures are handled by the game controller since only the VC has the connection between the cards in the game which is held by model and every individual card view.
 *
 *  @param tapGesture the sender of the event
 */
- (void)tap:(UITapGestureRecognizer *)tapGesture
{
  NSLog(@"\n");
  
  // find the index of the cardView that was tapped
  CGPoint tapLocation = [tapGesture locationInView:self.cardsDisplayArea];
  
  NSUInteger row = tapLocation.y / self.grid.cellSize.height;
  NSUInteger col = tapLocation.x / self.grid.cellSize.width;
  NSUInteger visibleCardIndex = row * self.grid.columnCount + col;
  
  if (visibleCardIndex >= self.game.curNumberOfCardsInGame) {
    NSLog(@"Touched outside visible cards - ingnoring the touch");
    return;
  }
  
  NSUInteger chosenCardIndex = [self translateToGameIndexFromVisibleIndex:visibleCardIndex];
  
  // Perform the game logic
  [self.game choseCardAtIndex:chosenCardIndex];
  
  // At every move there will be exactly one card to reveal / select, this is the card that was tapped on
  g_cardToChose = [self.cardViews objectAtIndex:chosenCardIndex];
  
  // And there will be 0 or more cards to flip back / de-select (if the current move didn't result in match)
  [g_cardsToDeselect removeAllObjects];
  
  // If there was a match the resulted cards must be removed from the game
  [g_cardsToRemove removeAllObjects];
  
  for (int i = 0; i < [self.cardViews count]; i++) {
    
    // get a card from the model and its corresponding view
    // Both game model and the cardViews hold all the cards that are/were in the game
    // The cards that previously been matched are not shown
    // This implementation makes game logic simplier and adheres to the assignment recommendation
    Card *card = [self.game cardAtIndex:i];
    CardView *cardView = self.cardViews[i];
    
    // Model ('card') already holds the next game state, while the View is only being updated right now
    // so 'card' is the next state and 'cardView' is the current state
    
    if (card.isChosen != [cardView getSelectedState]) { // faceUp for the Playing card and isSelected for Set card
      // reveal or flip back
      if (card.isChosen) {
        // there should be only one card sutisfing this condition, this is cardToChose
      } else {
        [g_cardsToDeselect addObject:cardView];
      }
    }
    
    if (card.isMatched != cardView.hidden) {
      // isHidden is NO. It can't be that the card is hidden in prev round, but is matched in this round
      if (card.isMatched) {
        [g_cardsToRemove addObject:cardView];
      }
    }
    
    // Although animating step outcome will take some time to complete (about 1 sec), the label with the score will be updated here for code simplicity
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
  }
  
  // Now we can animate all the changes
  //  1. reveal / select the card
  // [2. flip back / deselect card(s)
  // [3. remove matched cards]
  // [4. rearrange remaining cards]
  // [5. check for game over, if game over - reveal remaining cards]

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardSelectionCompleted:) name:CARD_SELECTION_COMPLETED_NOTIFICATION object:g_cardToChose];

  [g_cardToChose toggleSelectedState];
}


# pragma mark - Outcome Animation Sequence

/**
 *  Callback function to the notification of the card selection completion. The card selection is always the first step in any user interaction. There might be more steps in animating the user interaction outcome. However this might also be the single step to process.
 *
 *  @param notification notification. Must be CARD_SELECTION_COMPLETED_NOTIFICATION
 */
- (void)cardSelectionCompleted:(NSNotification *)notification
{
  NSLog(@"Start processing notification: %@", notification.name);
  
  SYSASSERT([notification.name isEqualToString:CARD_SELECTION_COMPLETED_NOTIFICATION],
            ([NSString stringWithFormat:@"Unexpected notification. Expected notification: %@, recieved: %@",
              CARD_SELECTION_COMPLETED_NOTIFICATION, notification.name]));

#warning is this the right place to remove observer?
  [[NSNotificationCenter defaultCenter] removeObserver:self name:notification.name object:g_cardToChose];
  
  
  // one card has been just flipped over to face up state.
  // There are 3 distinct possibilities -
  // 1) Nothing else has to be done, there were not enough cards chosen to perform match
  // 2) There are cards that have to be deselected
  // 3) There are cards that have to be removed
  
  NSUInteger numOfCardsToRemove   = [g_cardsToRemove count];
  NSUInteger numOfCardsToDeselect = [g_cardsToDeselect count];
  
  SYSASSERT((g_cardsToDeselect && g_cardsToDeselect), @"Arrays should not be nil");
  NSLog(@"CardsToDeselect count: %d, CardsToRemove count: %d", numOfCardsToDeselect, numOfCardsToRemove);

  // Option 1
  if (!numOfCardsToDeselect && !numOfCardsToRemove) {
    NSLog(@"After card selection there is nothing more to do.");
    
  // Option 2
  } else if (numOfCardsToDeselect) {
    NSLog(@"Deselecting other cards");
    for (CardView *cardView in g_cardsToDeselect) {
      [cardView toggleSelectedState];
    }
    
  // Option 3
  } else if (numOfCardsToRemove) {
    NSLog(@"Removing cards");
    
    [UIView transitionWithView:self.view
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                      for (CardView *cardView in g_cardsToRemove) {
                        cardView.hidden = YES;
                      }
                    }
                    completion:^(BOOL finished) {
                      if (finished && ([g_cardsToRemove count] == 0)) {
                        if (self.game.curNumberOfCardsInGame == 0) {
                          [self checkForGameOver];
                        } else {
                          NSLog(@"finished removing card views");
                          [self rearrangeCardViewsWithCheckForGameOver:YES];
                        }
                      }
                    }];
  } else { // error
    SYSASSERT(0, @"Cards existing both in array for removal and array for deselection.");
  }
  
  [g_cardsToDeselect removeAllObjects];
  [g_cardsToRemove removeAllObjects];
  NSLog(@"Finished processing notification: %@", notification.name);
}

- (BOOL)gridNeedsUpdate
{
  BOOL gridHasChanged = NO;
  
  NSLog(@"self.grid.minimumNumberOfCells = %d, [self.game curNumberOfCardsInGame] = %d",
        self.grid.minimumNumberOfCells, [self.game curNumberOfCardsInGame]);
  
  // The grid can change as a result of: 1) device rotation change 2) change in munber of cards (it can increase or decrease)
  if (self.grid.size.width != self.cardsDisplayArea.frame.size.width ||  // it is enough to compare only one demension since they are tight by aspect ratio
      self.grid.minimumNumberOfCells != [self.game curNumberOfCardsInGame]){
    
    gridHasChanged = YES;
  }
  NSLog(@"GridNeedsUpdate: %d", gridHasChanged);
  
  return gridHasChanged;
}


/**
 *  Recalculate size and position of the card views that are currently in play.
 *
 *  @return if there were actual changes in the cards layout (either size or position or both of at least one card)
 */
- (BOOL)rearrangeCardViewsWithCheckForGameOver:(BOOL)shouldCheckForGameOver
{
  NSLog(@"updateGridAndRearrangeCardViewsIfNeeded");
  
  SYSASSERT((self.grid.cellAspectRatio != 0), @"Grid cell aspect ratio must be set and different from 0");
  
  __block BOOL cardsWereRearranged = NO;
  
  NSLog(@"self.grid.minimumNumberOfCells = %d, [self.game curNumberOfCardsInGame] = %d", self.grid.minimumNumberOfCells, [self.game curNumberOfCardsInGame]);
  
  // grid setup
  self.grid.size = self.cardsDisplayArea.frame.size;
  self.grid.minimumNumberOfCells = [self.game curNumberOfCardsInGame];
  SYSASSERT(self.grid.inputsAreValid, @"Grid inputs are invalid");
  
  
  // first find all the cardViews that are currently visible
  NSMutableArray *visibleCardViews = [NSMutableArray new];
  NSUInteger currVisibleInd = 0;
  
  for (NSUInteger currInd = 0; currInd < [self.cardViews count]; currInd++) {
    
    CardView *cardView = self.cardViews[currInd];
    
    if (!cardView.isHidden) {
      [visibleCardViews addObject:cardView];
      currVisibleInd++;
    }
  }
  
  // now that we have all the visible cardViews in one array, we can calculate new frame for each of them
  // it is also possible that there were no changes in the layout, that's why there is an indication for the caller should it be interested
  [UIView transitionWithView:self.view
                    duration:0.3
                     options:UIViewAnimationOptionTransitionNone
                  animations:^{
                    [visibleCardViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                      CardView *cardView = (CardView *)obj;
                      CGRect frame = [self getFrameForViewAtIndex:idx];
                      
                      // If cards need to be rearranged then at least one of them will have new origin
                      // and we need to find only one such card to determine this
                      if (!cardsWereRearranged) {
                        if ((abs(cardView.frame.origin.x - frame.origin.x) > 0.001) ||
                            (abs(cardView.frame.origin.y - frame.origin.y) > 0.001)){
                          cardsWereRearranged = YES;
                        }
                      }

                      cardView.frame = frame;
                    }];
                  }
                  completion:^(BOOL finished) {
                    if (finished) {
                      NSLog(@"finished rearranging");
                      if (shouldCheckForGameOver) {
                        [self checkForGameOver];
                      }
                    }
                  }];
  
  
  NSLog(@"updateGridAndRearrangeCardViewsIfNeeded returning: %d", cardsWereRearranged);
  return cardsWereRearranged;
}


#pragma mark - Game Over Handling

/**
 *  Check if there are more matches available with the remaining cards
 */
- (void)checkForGameOver
{
  NSLog(@"Checking for game over");
  if(![self.game moreMatchesAvailable]) {
    
    NSString *msg = nil;
    
    if (self.game.curNumberOfCardsInGame) {
      // There are cards left but they can't be matched --> it's kindof Lose
      [self revealCardsForGameOver];
      msg = [NSString stringWithFormat:@"There are no more matches with the remaining cards"];
    } else {
      // no more cards left - kindof Win
      msg = [NSString stringWithFormat:@"Congratulations!\nYou've matched 'em all"];
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Game Over"
                                message:msg
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:@"Start New Game", nil] show];
     }
}

/**
 *  Reveal all the remaining cards (flip them face up). It will happen only when there are no more matches available with the remaining cards
 */
- (void)revealCardsForGameOver
{
  NSLog(@"Revealing cards for game over");
  
  for (CardView *cardView in self.cardViews) {
    if ((!cardView.isHidden) && (!cardView.isFaceUp)) {
      [cardView toggleSelectedState];
    }
  }
}


#pragma mark - Views Creation (Aux Methods)

/**
 *  Add views of type CardView to the curent game. This method is called after the cards had been added to the game in the model.
 *
 *  @param fromInd the first index in the grid to place the first of the new CardView's
 *  @param toInd   the last index in the grid to place the last of the new CardView's
 *  @param delay   delay for animating the card arrival on screen
 */
- (void)addViewsForCardsFromIndex:(NSUInteger)fromInd toIndex:(NSUInteger)toInd animateWithDelay:(CGFloat)delay
{
  NSLog(@"fromInd = %d, toInd = %d", fromInd, toInd);

  for (NSUInteger cardInd = fromInd; cardInd <= toInd; cardInd++) {
    
    NSUInteger gridIndex = [self nextAvailableVisibleIndex];
    
    CGRect frame = [self getFrameForViewAtIndex:gridIndex];
    
    Card *card = [self.game cardAtIndex:cardInd];
    SYSASSERT(card, @"Card should not be nil");
    
    CardView *cardView = [self createCardViewWithFrame:frame withCard:card];
    SYSASSERT(cardView, @"CardView should not be nil");
    
    [self.cardViews addObject:cardView];
    [self.cardsDisplayArea addSubview:cardView];
    
    // animate the card arrival from the bottom right corner.
    CGRect initialFrame = cardView.frame;
    initialFrame.origin = self.view.frame.origin;
    initialFrame.origin.x += self.view.frame.size.width;
    initialFrame.origin.y += self.view.frame.size.height;
    
    [cardView animateCardFrameChangeFromFrame:initialFrame toFrame:cardView.frame withDuration:CARD_ARRIVAL_ON_DEAL_ANIMATION_DURATION withDelay:delay];
    delay += 0.1f;
    
    NSLog(@"Added at the index %d: CardView - %@, Card - %@", cardInd, cardView.contents, card.contents);
  }
}


/**
 *  The index of the first available space in the grid
 *
 *  @return index in the grid
 */
- (NSUInteger)nextAvailableVisibleIndex
{
  NSUInteger visibleIndex = 0;
  
  for (int i = 0; i < [self.cardViews count]; i++) {
    if (![self.cardViews[i] isHidden]) {
      visibleIndex++;
    }
  }
  return visibleIndex;
}


/**
 *  Given a view index within the grid return the frame for this view
 *
 *  @param cardInd the index of the view
 *
 *  @return frame for this view
 */
- (CGRect)getFrameForViewAtIndex:(int)cardInd
{
  SYSASSERT(self.grid.inputsAreValid, @"Grid inputs are not valid");
  SYSASSERT(self.grid.columnCount, @"Grid column count cannot be 0");
  
  NSUInteger r = cardInd / self.grid.columnCount;
  NSUInteger c = cardInd % self.grid.columnCount;
  
  CGRect gridCell = [self.grid frameOfCellAtRow:r inColumn:c];
  
  // frames provided by grid take all the available space, so the frame for the card view
  // should be scaled a little in order to provide some spacing between them
  CGRect frame;
  frame.size.width  = gridCell.size.width * CARD_VIEW_SCALE_FACTOR;
  frame.size.height = gridCell.size.height * CARD_VIEW_SCALE_FACTOR;
  
  // Also the frame must be positioned in the center of the grid cell
  frame.origin.x = gridCell.origin.x + (gridCell.size.height - frame.size.height) / 2;
  frame.origin.y = gridCell.origin.y + (gridCell.size.width - frame.size.width) / 2;
  
  return frame;
}


/**
 *  Translate index from the game model logic which holds all the cards that ever were dealt in this game, in their original order to the grid of the visible cards only. Index in the grid is calculated from the tap gesture recogniser, to translate it to the game logic index the visible index must be offset by amount of the hidden cards upto this particular index
 *
 *  @param visibleCardIndex index in the grid of visible cards
 *
 *  @return index in the game array of cards
 */
- (NSUInteger)translateToGameIndexFromVisibleIndex:(NSUInteger)visibleCardIndex
{
  NSUInteger chosenCardIndex = visibleCardIndex; // it is at least a visibleCardIndex
  NSUInteger visibleCards = 0;
  
  SYSASSERT([self.cardViews count], @"Index translation error: CardViews array is empty.");
  
  for (int i = 0; i < [self.cardViews count]; i++) {
    if (![self.cardViews[i] isHidden]) {
      visibleCards++;
    }
    
    if (visibleCards == visibleCardIndex + 1) {
      chosenCardIndex = i;
      break;
    }
  }
  return chosenCardIndex;
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
