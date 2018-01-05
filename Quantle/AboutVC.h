//
//  AboutVC.h
//  Quantle
//
//  Created by Olga Saukh on 5/05/17.
//  Copyright (c) 2017 chatterboxbit.com. All rights reserved.
//
//  Quantle is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Quantle is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Quantle.  If not, see <http://www.gnu.org/licenses/>.
//

#import <UIKit/UIKit.h>

/**
 * The AboutViewController class is responsible for the About navigation tab.
 * The tab is used to display details about the OpenSense project, the app,
 * and provides contact information.
 */
@interface AboutVC : UIViewController

/**
 * The text field in the About tab displaying information about the app.
 */
@property (weak, nonatomic) IBOutlet UITextView *aboutTextView;

@end
