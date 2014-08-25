This project is a homework assignment from the "Developing iOS 7 apps for iPhone and iPad" course by Standford University, 
fall-winter 2013. (Course link: https://itunes.apple.com/us/course/developing-ios-7-apps-for/id733644550)

The app plays two card matching games in two separate tabs. One game is a paying card game and the other is Set game (see wikipedia article on it: )

This project is developed in educational purposes in my spare time. The code in the project primarily written solely by myself with exception 
of the code that was provided in the lectures. I did not take a single line from other people's solutions for this assignement.

The app is polished on the best-effort basis. i.e. it is not fancy looking (at this stage at least) as a good paying app would be. 

NOTES:
0. The app is in development. Some features are not yet implemented, some failures are known, but not yet fixed. For the list of todo items scroll down
1. Although it was more natural to use UICollectionView, I chose not to use to comply with the requirements more closely. The Grid class was provided by the course. It is designed to span from left to right border of the provided space and respect the aspect ratio, and in this way sometimes it may seem that the spaces is not used effectevily, e.g. 4 cards laid out in 2 rows - 3 in the first row and 1 in the second. If instead it were center-based then there would be 2 rows with 2 cards in each and every card would appear bigger.
2. In the Set game the Squiggle shape is represented by triangle and the stripping is represented with the shading. It was requirement to use UIBezierPath for this assignement, which I did with reasonable amount of time dedicated to this aspect. I prefer not to waste any more time on the Bezier paths at this point of my education.
3. The base Card class in the model is abstract class though it shouldn't be. However in this particular assignment due to time constraints I deliberately leave it
abstract
4. Assertions will be taken care of later. Although they are claimed to be unpredictable in my case they are - I use 1 thread and I always look at console. They provide the convenience of constructing custom message and therefore are prefect for my current needs.


TODO:
1. Animations - must be sequenced. Currently because of the animations going in parallel it is hard to understand what is going on.
2. Buttons dissapear when switching from one tab to another. Switching orientation restores them. 
3. Game over - some not very nice code. Need to be replaced with something more sensible and also notify user in a nice way. 
