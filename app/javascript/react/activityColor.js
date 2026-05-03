const COLORS = Array.from({ length: 30 }, (_, i) =>
  `hsl(${Math.round((i * 137.508) % 360)}, 65%, 52%)`
);

export function activityColor(activityId) {
  let hash = 0;
  for (let i = 0; i < activityId.length; i++) {
    hash = ((hash << 5) - hash) + activityId.charCodeAt(i);
    hash |= 0;
  }
  return COLORS[Math.abs(hash) % COLORS.length];
}
