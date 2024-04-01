# Farm Defense
**Objective:** Defend yourself against a UFO abducting your cows and shooting them at you! Use your chicken gun to shoot eggs at the UFO and bring it down!

**Supported Platforms:** PC, Mobile, and Console

# Challenge Specifics
**Codebase:** The codebase is thorougly documented & typechecked to ensure clarity for other developers and simplify reviewing. In addition, composure is used in some systems such as the UFO where the launcher is used to launch cows at the player. All programming decisions are also thoroughly commented to explain my technical thought process.

**Knit Usage:** Instead of using services/controllers for everything (see https://medium.com/@sleitnick/knit-its-history-and-how-to-build-it-better-3100da97b36), I opted to use both services/controllers and local/server scripts. As an example, I opted to make ``Collisions.server.lua`` instead of putting it into ``GameService`` or its own ``CollisionService``. In addition, I also created a seperate script for my react mounter instead of creating a controller to handle mounting.

**GitHub Usage:** I utilized Pull Requests and Conventional Commit messages for this project. As such, you can look at any pull request and look at individual commits to clearly see how I built the game up from scratch.

**Physics Integration:** Physics is an essential part of gameplay because both the attacking UFO and you use projectile-based weapons. Physics are integrated through the FastCastRedux dependency. In addition to this, you can control how far your projectile can go by aiming up or down

**Humor:** Humor is implemented through the sound effects ingame as well as the game itself. The idea of a UFO stealing your cows and shooting them at you and using a chicken to shoot eggs are both comical aspects of gameplay.

**Future Plans:** If I were to ever revisit this game, there's some gameplay changes I'd love to make. First, I'd add a lobby system so multiplayer could be implemented without hastle and you can jump right into the game without waiting for the current round to end. In addition, I'd add new animals such as sheep and pigs as the codebase is modular & would allow for such. I'd also add player powerups so they can increase their damage or regenerate some health. I'd also add greater feedback for damaging both players and enemies (likely a red highlight alongside damage sounds). Finally, I'd add some more attacks to the UFO and potentially even an alien humanoid that runs at you to try and jam your chicken launcher.

**Time Spent:** In total, around 10 hours were spent working on the game across four days.

