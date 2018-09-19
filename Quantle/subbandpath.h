//
//  subbandpath.h
//  Quantle
//
//  Created by Olga Saukh on 10.09.18.
//  Copyright © 2018 Olga Saukh. All rights reserved.
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

#ifndef subbandpath_h
#define subbandpath_h

#ifdef __cplusplus
extern "C" {
#endif
    
    void FFT(short int dir, int m, float *x, float *y);
    
#ifdef __cplusplus
} // extern "C"
#endif

#endif /* subbandpath_h */
