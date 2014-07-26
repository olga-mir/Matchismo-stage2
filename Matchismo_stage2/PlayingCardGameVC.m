//
//  PlayingCardGameVC.m
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "PlayingCardGameVC.h"
#import "PlayingCardDeck.h"
#import "PlayingCardView.h"
#import "PlayingCard.h"

@interface PlayingCardGameVC ()

@property (weak, nonatomic) IBOutlet PlayingCardView *playingCardView;

@property (strong, nonatomic) PlayingCardDeck *deck; // TODO - move to right place

@end

@implementation PlayingCardGameVC

// TODO - move to the right place
- (Deck *)deck
{
  if (!_deck) _deck = [[PlayingCardDeck alloc] init];
  return _deck;
}

- (void)drawRandomPlayingCard
{
  Card *card = [self.deck drawRandomCard];
  if ([card isKindOfClass:[PlayingCard class]]) {
    PlayingCard *playingCard = (PlayingCard *)card;
    self.playingCardView.rank = playingCard.rank;
    self.playingCardView.suit = playingCard.suit;
  }
}

- (Deck *)createDeck
{
  NSLog(@"PlayingCardGameVC: createDeck");
  return [[PlayingCardDeck alloc] init];
}

- (NSUInteger)numOfCardsToMatch {
  NSLog(@"PlayingCardGameVC: set num of cards to match (2 for the playing card game)");
  return 2;
}

- (IBAction)swipe:(UISwipeGestureRecognizer *)sender {
  // TODO - here for dev phase - need to be moved to parent class
  
  if (!self.playingCardView.faceUp) {
    [self drawRandomPlayingCard];
  }
  self.playingCardView.faceUp = !self.playingCardView.faceUp;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  NSLog(@"PlayingCardGameVC: viewDidLoad");
  
  // TODO - here for dev phase - need to be moved to parent class

  self.playingCardView.suit = @"♥"; // temp code to test
  self.playingCardView.rank = 9;  // temp code to test
  
  [self.playingCardView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.playingCardView action:@selector(pinch:)]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
