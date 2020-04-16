# Quantle App

[Quantle](http://www.olgasaukh.com/quantle) is mobile app which implements a digial presentation coach. It is written for iOS and is available through [iTunes apple store](https://itunes.apple.com/us/app/quantle/id1241930976?mt=8). Quantle is **free of charge** an **open source**. Quantle code is available on [GitHub](https://github.com/osaukh/quantle_app).

Quantle stems from a research community where the need for a socially unbiased presentation coach is high. To find more information about the performance of Quantle, please see our [paper](https://bit.ly/2Oaa0FK.saukh19quantle.pdf).

Quantle estimates the number of syllables and words the speaker says, computes the length of pauses, estimates pace, pitch, power of the delivery and, most importantly, variability of the characteristics throughout the talk. The app development is inspired by the need to evaluate talk effectiveness without a human coach in a fair, repeatable, and (socially) unbiased way. Quantle works for languages in which the number of syllables in a word is determined by the number of vowels, although we tuned Quantle primarily for the English language. 

### Features
* Quantle respects user's privacy. Quantle neither stores the audio nor communicates any of its parts. Microphone data is processed in chunks and destroyed immediately afterwards. See our [privacy policy](PRIVACY_POLICY.md).
* Pace, pause, pitch & power analysis.
* Quantle estimates complexity of a talk by computing complexity metrics (=adapted readability metrics from the literature).
* Good presentation style is a matter of personal taste. Quantle achieves fairness and repeatability by providing a digital presentation coach which lacks social bias.
* Quantle maintains a history of talk evaluations to track the progress as we rehearse.
* The app is free of charge and the code is open source ([MIT license](LICENSE.txt)).

If you have any questions, please do not hesitate to contact us: chatterboxbit@gmail.com.

### Reference

If you use the code please cite:

<pre>@inproceedings{saukh2019quantle, 
  author = {Saukh, Olga and Maag, Balz}, 
  title = {Quantle: Fair and Honest Presentation Coach in Your Pocket}, 
  year = {2019}, 
  publisher = {Association for Computing Machinery}, 
  doi = {10.1145/3302506.3310405}, 
  booktitle = {Proceedings of the 18th International Conference on Information Processing in Sensor Networks}, 
  pages = {253–264}, 
  series = {IPSN ’19}
}</pre>
