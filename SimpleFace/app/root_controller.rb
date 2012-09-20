class RootController < UIViewController

  def viewDidLoad
    super

    view.backgroundColor = UIColor.lightGrayColor

    @markie = UIImage.imageNamed("markie.jpeg")
    cme = CIImage.alloc.initWithImage(@markie)

    options = NSDictionary.dictionaryWithObject(CIDetectorAccuracyHigh, forKey:CIDetectorAccuracy)
    detector = CIDetector.detectorOfType(CIDetectorTypeFace, context:nil, options:options)

    features = detector.featuresInImage(cme)

    Dispatch::Queue.concurrent.async do
      print_features(features)
    end
  end

private

  def print_features features

    # Creates a bitmap-based graphics context with the specified options.
    UIGraphicsBeginImageContextWithOptions(@markie.size, true, 0)

    # Draws the UIImage (markie) into a rect
    @markie.drawInRect([[0, 0], @markie.size])

    # Returns the current graphics context.
    currentContext = UIGraphicsGetCurrentContext()

    # Modify the x and y coordinates of each point by a specified amount
    CGContextTranslateCTM(currentContext, 0, @markie.size.height)

    # Specify the x and y scaling factors
    CGContextScaleCTM(currentContext, 1, -1)

    scale = UIScreen.mainScreen.scale # => 1.0

    features.each_with_index do |feature, index|
      
      # TODO: get some of this out of the loop
      CGContextSetRGBFillColor(currentContext, 1, 1, 1, 0.4)
      CGContextSetStrokeColorWithColor(currentContext, UIColor.whiteColor.CGColor)
      CGContextSetLineWidth(currentContext, 2)
      CGContextAddRect(currentContext, feature.bounds)
      CGContextDrawPath(currentContext, KCGPathFillStroke)

      CGContextSetRGBFillColor(currentContext, 0, 1, 0, 0.4)

      p "Found Feature!"
      
      if feature.hasLeftEyePosition
        draw_feature(currentContext, atPoint:feature.leftEyePosition)
        p "Left Eye Coord: #{feature.leftEyePosition.x}x#{feature.leftEyePosition.y}"
      end
      if feature.hasRightEyePosition
        draw_feature(currentContext, atPoint:feature.rightEyePosition)
        p "Right Eye Coord: #{feature.rightEyePosition.x}x#{feature.rightEyePosition.y}"
      end
      if feature.hasMouthPosition
        draw_feature(currentContext, atPoint:feature.mouthPosition)
        p "Mouth Coord: #{feature.mouthPosition.x}x#{feature.mouthPosition.y}"
      end
    end

    # Do we need this?
    # newView = UIImageView.alloc.initWithFrame([[0, 0], @markie.size])
    # newView.image = UIGraphicsGetImageFromCurrentImageContext()
    
    # Creates a new view and draws the current bitmap in context to it
    newView = UIImageView.alloc.initWithImage(UIGraphicsGetImageFromCurrentImageContext())
    newView.frame = CGRectMake(0, 0, @markie.size.width, @markie.size.height)
    
    # Removes the current bitmap-based graphics context from the top of the stack.
    UIGraphicsEndImageContext()

    view.addSubview(newView)
  end

  def draw_feature(context, atPoint:feature_point)
    size = 6
    startx = feature_point.x - (size/2)
    starty = feature_point.y - (size/2)
    CGContextAddRect(context, [[startx, starty], [size, size]])
    CGContextDrawPath(context, KCGPathFillStroke)
  end
  
end
