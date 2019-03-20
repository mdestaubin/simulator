public class DEswatch
{
      
      color[] DE;
  
      public DEswatch()
      {
           DE = new color [100];
           
           DE[5] = (int) color(8,81,156);     // degree 0.0 - 7.0
           DE[4] = (int) color(224, 172, 100);   // degree 7.0 - 11.0
           DE[3] = (int) color(183, 135, 67);  // degree 11.0-18.0
           DE[2] = (int) color(224, 172, 100);  // degree 18.0-25.0
           DE[1] = (int) color(255,255,255);        // degree 25.0-45.0
           DE[0] = (int) color(0,0,0);  // degree 45.0-90.0  not accessible 

      };

      color getColor( int DEcode )
      {  
            color defaultColor = color(239,243,255); // enter an invalid code number and
                                               // get K back.
            
            return (DEcode <= 255 && DEcode > 0)? DE[ DEcode ] : defaultColor;
      }
  
      color[] getSwatch()
      {
          return DE;
      }
}
