//
//  h1
//
//  Created by Clayton Zug on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


@implementation UILabel (VerticalAlign)
//- (void)alignTop {
//    CGSize fontSize = [self.text sizeWithFont:self.font];
//    double finalHeight = fontSize.height * self.numberOfLines;
//    double finalWidth = self.frame.size.width;    //expected width of label
//    CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
//    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
//    for(int i=0; i<newLinesToPad; i++)
//        self.text = [self.text stringByAppendingString:@"\n "];
//}
//
//- (void)alignBottom {
//    CGSize fontSize = [self.text sizeWithFont:self.font];
//    double finalHeight = fontSize.height * self.numberOfLines;
//    double finalWidth = self.frame.size.width;    //expected width of label
//    CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
//    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
//    for(int i=0; i<newLinesToPad; i++)
//        self.text = [NSString stringWithFormat:@" \n%@",self.text];
//}
@end