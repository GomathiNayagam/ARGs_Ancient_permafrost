library(ggplot2)  # For creating plots
library(tidyr)    # For reshaping data

data <- data.frame(
  Category = c("Ancient Pristine", "Contemporary Pristine", 
               "Contemporary Agriculture", "Contemporary Bareland"),
  `Antibiotic inactivation` = c(0.200, 0.233, 0.259, 0.268),
  `Antibiotic efflux` = c(0.327, 0.371, 0.214, 0.474),
  `Antibiotic target protection/alteration/replacement` = c(0.473, 0.395, 0.527, 0.258)
)

data$Category <- factor(data$Category, levels = c(
  "Ancient Pristine", 
  "Contemporary Pristine", 
  "Contemporary Agriculture", 
  "Contemporary Bareland"
))


data_long <- pivot_longer(
  data, 
  cols = -Category, 
  names_to = "Mechanism", 
  values_to = "Proportion"
)


significance_annotations <- data.frame(
  xstart = c(1, 1, 1, 2, 2, 3),  
  xend = c(2, 3, 4, 3, 4, 4),    
  y_position = c(1.10, 1.25, 1.40, 1.55, 1.70, 1.85),  
  label = c(
    "\nNS ",    # Not significant: Ancient Pristine vs Contemporary Pristine
    "\n** ",    # Significant: Ancient Pristine vs Contemporary Agriculture
    "\n** ",    # Significant: Ancient Pristine vs Contemporary Bareland
    "\n** ",    # Significant: Contemporary Pristine vs Contemporary Agriculture
    "\n** ",    # Significant: Contemporary Pristine vs Contemporary Bareland
    "\n** "     # Significant: Contemporary Agriculture vs Contemporary Bareland
  )
)

# Specify the name for the output file
output_file <- "xxx_stacked_bar_chart.tiff"

# Save the plot as a PNG file
png(filename = output_file, width = 1200, height = 800, res = 300)

# Create the stacked bar plot
ggplot(data_long, aes(x = Category, y = Proportion, fill = Mechanism)) +
  geom_bar(stat = "identity", position = "stack", width = 0.7) +  # Stacked bar chart
  scale_fill_brewer(palette = "Set2", name = "Mechanism") +       # Use colour palette
  labs(
    x = "Category", 
    y = "Proportion", 
    title = "Mechanisms of Antibiotic Resistance Across Categories"
  ) + 
  theme_minimal(base_size = 14) +                                 
  geom_segment(
    data = significance_annotations,
    aes(x = xstart, xend = xend, y = y_position - 0.03, yend = y_position - 0.03),
    inherit.aes = FALSE, size = 0.6, colour = "black"
  ) +  
  geom_text(
    data = significance_annotations,
    aes(x = (xstart + xend) / 2, y = y_position, label = label),
    inherit.aes = FALSE, size = 4
  ) +  
  theme(legend.position = "bottom") +                            
  ylim(0, 2.0)  


dev.off()

