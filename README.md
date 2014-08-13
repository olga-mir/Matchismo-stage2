This project is a homework assignment from the "Developing iOS 7 apps for iPhone and iPad" course by Standford University, 
fall-winter 2013. (Course link: https://itunes.apple.com/us/course/developing-ios-7-apps-for/id733644550)

The app plays two card matching games in two separate tabs. One game is a paying card game and the other is Set game (see wikipedia article on it: )

This project is developed in educational purposes in my spare time. The code in the project primarily written solely by myself with exception 
of the code that was provided in the lectures. I did not take a single line from other people's solutions for that assignement.

The app is polished on the best-effort basis. i.e. it is not fancy looking (at this stage at least) as a good paying app would be. 

NOTES:
0. The app is in development. Some features are not yet implemented, some failures are known, but not yet fixed. For the list of todo items scroll down
1. The grid class used to layout frames was provided by the course. It is designed to use all the horizontal space, which is not always optimal 
use of the screen. For example when 4 cards left they will sit in two rows - 3 in the first and one in the second. But better layout will be 2x2 centered in the middle
2. The base Card class in the model is abstract class though it shouldn't be. However in this particular assignment due to time constraints I deliberately leave it
abstract


TODO:
1. Set Game is not yet implemented. Trying to navigate to Set tab will crash the app because the deck cannot be allocated
2. No game over - when all cards matched - the app crashes (from Assert), if the remaining cards cannot be matched they stay forever on screen (or until user touches Deal button)
3. 
