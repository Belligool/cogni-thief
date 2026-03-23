# Immersive Particle VFX for Ren'Py by Feniks (https://feniksdev.com/) v1.1

https://feniksdev.itch.io/immersive-particle-vfx-for-renpy

Included are several code files which enable various particle effects in Ren'Py. To get started, there is an included walkthrough in the file particle_examples.rpy. You can jump to the label `test_particles` for a tutorial and showcase of the particle effects.

You should place the included files into your own game/ folder. So, the final structure should look like:

game/libs/immersive_particle_vfx/(....).rpy
game/images/ImmersiveParticleVFX/feniks snow dust fireflies rain/
game/particle_examples.rpy

You may remove the particle_examples label when you're finished with it; it isn't required to run this tool.

## Configuration Values

This tool comes with three configuration values:

`particle_config.CREATE_STATIC_VARIANTS = True`

If True, the default, this tool will automatically create ConditionSwitch variants of particle animations. The ConditionSwitch condition depends on the next configuration value.

`particle_config.STATIC_CONDITION = "persistent.particle_animations_off"`

This is the condition which will cause static variants of a particle animation to be shown instead of the moving animation. If you leave the defaults as-is, you can create a button in your settings screen with the action `ToggleField(persistent. "particle_animations_off")` so players can turn animations on and off as they please.

`particle_config.NULL_INSTEAD_OF_STATIC = False`

If False, the default, the ConditionSwitch created for particle animations will default to using a static version of the provided animation when the STATIC_CONDITION is True. If True, then instead of a static image, Null() will be used (aka a blank image). You can supply individual particle animations with your static displayable of choice via the `static_displayable` argument.

## Base ImmersiveParticles arguments

The base ImmersiveParticles class comes with many, many properties. These are explained in the class declaration, and also below:

Aside from image, all parameters should be provided as keyword arguments.

NOTE: Anytime `DISTRIBUTION` is specified as a possible value, it can be
a str or Callable in the following form:
    A function or the name of a built-in distribution function to
    determine the starting position of a particle.
    If a string, must be one of the following:
    - `"linear"`: Value has an equal chance of being anywhere along an axis.
    - `"gaussian"`: Value is more likely to be near the middle and less
        likely to be near the edges.
    - `"arcsine"`: Value is more likely to be near the edges and less
        likely to be near the middle.
    If a function, it must take two floats as arguments and return a float.

NOTE: Anytime `number or tuple` is specified as a possible value, it can
be of the following forms:
    - A single number: All particles will use this value. e.g. 50
    - A tuple of two numbers: Each particle will have a random value
        between the two numbers. e.g. (-20, 20)
    - A tuple of two numbers and a distribution: Each particle will have
        a random value between the two numbers, determined by the
        provided distribution. e.g. (50, 120, "linear")
    - A tuple of two numbers, a distribution, and a fourth number: Each
        particle will have a random value between the two numbers,
        determined by the distribution function. The distribution
        function will be passed the first two numbers along with the
        current time since the animation started and the fourth provided
        number. e.g. (50, 120, "linear", 10)

### General Properties

image : Displayable
    The displayable to use for the particles. (Renamed from `d`)
amount : int
    The number of particles to display. (Renamed from `count`)
particle_size : int or tuple
    The size of the particles. The particle is considered to be on the
    screen until its bounding box has cleared the area, ensuring that
    particles do not disappear abruptly. This can be a single integer, in
    which case it is used for all dimensions, or a tuple of two integers,
    in which case the first number is used for the xsize (width) and the
    second for the ysize (height). (Renamed and updated `border`)

### Speed and acceleration
xspeed, yspeed : number or tuple
    The speed of the particles in the x and y directions, respectively.
    See above for the possible formats. Mutually exclusive with
    specifying velocity and angle.
xacceleration, yacceleration : number or tuple
    The acceleration of the particles in the x and y directions,
    respectively. Negative numbers cause deceleration, regardless of
    whether the speed is negative or positive, and positive numbers
    always cause acceleration. (New)
velocity : number or tuple
    An alternate way to specify speed, alongside the angle property.
    This is mutually exclusive with specifying xspeed and yspeed.
    See above for the possible formats. (New)
angle : number or tuple
    An angle, in degrees from -360 to 360, which is used alongside the
    velocity property to specify the direction and speed of particles.
    0 degrees is 12:00, so from the bottom travelling straight up.
    90 degrees is 3:00, so from the left travelling straight right, and
    so on. (New)
acceleration : number or tuple
    An alternate way to specify acceleration, alongside velocity and
    angle. This is mutually exclusive with specifying xacceleration and
    yacceleration. As before, positive numbers cause acceleration and
    negative numbers cause deceleration, regardless of the angle or
    velocity. (New)

### Startup and delays
fast : bool
    If True, particles start in the center of the screen, with the full
    amount immediately visible. If False, they will begin falling from
    the edges of the area and take some time to reach the full amount.
    Default is False.
distribute_fast_start : float or None
    If not None, and fast is True, then rather than all particles
    starting at the exact same time, their start times will be evenly
    distributed from 0 to the provided time. This is most often useful
    as an inherited property for particles with lifetimes, to avoid
    all particles beginning on the exact same animation frame. Default
    is None. (New)
distribution : DISTRIBUTION
    A function or the name of a built-in distribution function to
    determine the starting position of a particle. As described above.
    Default is `linear`.
slow_start : float or None
    If not None, this is a float time in seconds during which the
    particles will be added to the area until reaching the usual
    particle starting pace. This can be used with slow_start_ramp to
    start fewer particles at the start of the animation, and then add
    more particles as the animation progresses. It needs to be at least
    as long as the time it takes for the slowest particle to clear
    the area (otherwise it'd just be starting at the usual pace).
    Default is None. (New)
slow_start_ramp : int
    If `slow_start` is not None, this should be an integer that's
    greater than 0. The higher the number, the more heavily particles
    will be favoured to start towards the end of the slow_start time.
    The default is 2, which has a gentle bias towards the end of the
    slow_start time. 1 is linear. (New)
delay : number or tuple or None
    The delay before a particle will reappear on the screen after it
    has left the area. If None, the default, particles will be queued
    immediately after they leave the particle area. Most useful with
    small numbers of particles, to prevent them from syncing up or
    looking too predictable. The delay does not affect particles during
    the initial startup time; only when it is time to restart. Default
    is 0. (New)
position_variance : float
    The amount of variance in the starting position of the particles.
    This number will be used along with the speed of the particle to
    begin it <random variance> seconds before its start position. This
    means particles do not all start at the same position (e.g. at the
    top of the screen), which avoids "line" effects due to the framerate
    syncing up the start time of particles. The exact variance is
    randomized between 0 and this value. Most useful for high numbers of
    particles or high particle speeds. Default is 0. (New)

### Positioning
xysize : (width, height) or None
    The width and height of the particle area, in pixels. If not
    provided, the screen size is used. Note that particles will be
    visible outside of this area if border is greater than 0, to prevent
    particles from popping in at the edges of the area. You can
    use `crop (0.0, 0.0, 1.0, 1.0)` to avoid this. (New)
origin_points : list of (x, y), dictionary, or None
    If provided, a list of (x, y) tuples representing points within
    the particle area where particles may originate. It may also be a
    dictionary, which takes the following keys:
    - points : list of (x, y)
        The list of origin points.
    - x_min : int or float or position
        The minimum x coordinate for origin points.
    - x_max : int or float or position
        The maximum x coordinate for origin points.
    - y_min : int or float or position
        The minimum y coordinate for origin points.
    - y_max : int or float or position
        The maximum y coordinate for origin points.
    - distribution : DISTRIBUTION
        A function or the name of a built-in distribution function to
        determine the starting position of a particle if using the
        min/max values.
    - hotspots : list of (x, y, w, h) tuples
        If provided, other keys are ignored. This is a list of hotspots
        in the format (x, y, w, h) where particles may spawn. For moving
        particles, this is treated as if it were its own area, so
        particles will spawn at the edges of the hotspot area and
        despawn once they have moved across it. New particles are shared
        across all hotspots. This can allow for custom placement of
        particles without requiring a unique mask.
    - function : Callable
        If provided, other keys are ignored. This is a function that is
        provided the width and height of the particle area, and returns
        an (x, y) tuple representing the origin point for a particle.
        This allows for complete customization over the origin point,
        e.g. spawning in a circle, or a triangle, etc.
    Either points or the min/max values must be provided as dictionary
    keys. If both are provided, only points is used.
    If not provided, particles begin from randomly offscreen. This
    allows for effects spawning from specific locations. (New)
force_direction : str or None
    If provided, must be one of 'vertical' or 'horizontal'. This
    forces all particles to consider their primary direction to be
    vertical or horizontal, respectively. This affects how particles
    are initially positioned when fast=False. If None, the primary
    direction is calculated based on the xspeed and yspeed values,
    which is usually accurate unless you have particularly diagonal
    particles. (New)
enter_exit_from_sides : bool
    If True, the default, particles are allowed to spawn in from the
    sides of the screen and will be removed if they go offscreen from
    the sides. The "sides" are the left/right sides for vertical
    particles and the top/bottom sides for horizontal particles.
    If False, particles will only spawn from the top/bottom for vertical
    particles and left/right for horizontal particles, and they will
    only be removed if they go offscreen in their primary direction.
    True will be more performant for full-screen animations or animations
    where the edges are hidden; False is useful if you're sequestering
    particles to certain areas but they might fall a little outside
    of that and you don't want them popping in/out of existence. (New)
creation_callback : callable
    If provided, a callable which takes two arguments. It is called
    when a new particle is created. The first argument is a dictionary
    of the properties of the particle, which can be modified. The
    second is the factory spawning the particle. It is not expected
    to return anything but may modify the dictionary.

### Masks and animation
animation : bool
    If True, then this animation uses the animation timebase.
    This prevents it from resetting when shown twice. Default is False.
update_frequency : float
    How often the animation is expected to be updating, at minimum. Gaps
    of 5*update_frequency or more will cause the animation to play catch
    up for missing particles. Set this number to higher values if you
    find the restart animations are occurring too frequently. Default
    is 1.0/30.0 aka 30FPS. (New)
mask_borders : integer/float/position, or tuple of such, or None
    If not None, this specifies a border where a gradient will be
    applied so particles fade in over that border size. You can provide
    a single number (float/int or position object), in which case the
    same border is applied to all sides. A tuple with two numbers is
    the xborder and yborder respectively, and a tuple with four numbers
    is the (left, top, right, bottom) borders respectively. (New)
circular_mask : bool
    If True, and mask_borders is provided, then instead of being a
    rectangular gradient, it will be elliptical from the edge of the
    particle effect. In this case, mask_borders should just be a
    singular number (float/int or position object) representing the
    border size. (New)

### Static variants
create_static : bool or None
    If None, the default, the creation of a static variant of this
    particle animation depends on the value of particle_config.CREATE_STATIC_VARIANTS.
    If True, the function will return a ConditionSwitch which only
    shows the particle animation if the condition provided in
    particle_config.STATIC_CONDITION is False. Otherwise, either a
    static variant of the animation will be generated, or a Null
    displayable if particle_config.NULL_INSTEAD_OF_STATIC is True. (New)
static_displayable : Displayable or None
    If provided, this displayable will be used as the static version of
    the animation when the condition in particle_config.STATIC_CONDITION
    is True, instead of generating a static version of the animation
    or using Null(). (New)
num_frames : int
    If a static variant is created, this is a number of frames an
    individual particle image has. This can be literal for frame-based
    animations, or just indicate the number of distinct time periods
    to use for the static version of the animation. (New)
frame_time_range : (float, float)
    A range of times during which the static frames can be captured for
    this animation. If the particle has a lifetime or distribute_fast_start,
    that will automatically be used if this is not provided. Otherwise,
    the default is (0.0, 1.0). (New)

### Inheritance

kind : Particles
    If provided, this should point to another ImmersiveParticles
    declaration. It can be provided the string name of a declared image,
    such as kind="snow_animation", or a direct reference to a Particles
    object. It can handle particles which are wrapped in ConditionSwitch
    and AlphaMask for static variants. The result is that the new
    ImmersiveParticles object will inherit all the properties of the
    provided one, except where new properties are supplied.

## Base CreateFlutterParticles arguments

CreateFlutterParticles takes all the same arguments as ImmersiveParticles, as well as:

flutter_xtime, flutter_ytime : number or tuple
    How long it takes for a particle to complete one full flutter cycle,
    that is, how long it takes to sway to the left, right, and back.
    Higher numbers result in slower fluttering, while lower numbers
    result in quick back and forth.
flutter_width : number or tuple
    The width of the fluttering motion in the x direction, in pixels.
flutter_height : number or tuple
    The height of the fluttering motion in the y direction, in pixels.
damp_xflutter, damp_yflutter : number or tuple
    If a positive number, the particle's x/y flutter will be dampened
    over the course of its lifetime (so it flutters less as it travels).
    If negative, the particle's x/y flutter will be un-dampened over the
    course of its lifetime (so it flutters more as it travels).
    The value is the percent of dampening that occurs. 1.0 or -1.0
    results in zero fluttering at the beginning/end of the particle's
    lifetime. A value like 0.5 results in the particle fluttering half
    as much at the end of its lifetime.
flutter_xacceleration, flutter_yacceleration : number or tuple
    The acceleration of the fluttering motion in the x/y direction.
    Positive numbers increase the time it takes to complete a flutter
    cycle (has the effect of making it sway more slowly as it travels),
    while negative numbers decrease the time it takes to complete a
    flutter cycle (has the effect of making it sway more quickly as it
    travels).
start_anywhere : bool
    If True, the particles can start anywhere on the screen when they
    are added (not just when the image is first shown). This is
    different from fast=True, as particles will still start slowly over
    time. They are simply allowed to start anywhere on-screen. Default
    is False.
lifetime : number or tuple
    The lifetime of the particle, in seconds. If None, the particle
    will disappear when it goes offscreen.
strict_offscreen : bool
    If True, the particle will be removed immediately when it goes
    offscreen, including if it sways offscreen due to fluttering.
    If False, the default, the particle will only be removed if no
    amount of flutter or regular movement can bring it back onscreen.
    Default is False.

## Base CreatePerspectiveParticles arguments

CreatePerspectiveParticles takes the following arguments the same as ImmersiveParticles:

- image
- amount
- particle_size
- fast
- distribute_fast_start
- distribution
- slow_start
- slow_start_ramp
- delay
- xysize
- animation
- update_frequency
- creation_callback
- mask_borders
- circular_mask
- create_static
- static_condition
- static_displayable
- num_frames
- frame_time_range

As well as the following:

min_scale : float
    The minimum scale of the particle when it is at the top of
    the area. (New)
max_scale : float
    The maximum scale of the particle when it is at the bottom
    of the area. (New)
stages : int
    The number of scaling stages to use between min_scale and
    max_scale. More stages results in smoother scaling, but
    requires more memory. (New)

## Creating Spritesheet Animations

Also included is a BasicSheetAnim class. It takes an animation split up as a grid on a single image and turns it into an animation. It takes the following properties:

sheet : Displayable
    The sprite sheet image.
cols : int
    The number of columns in the sprite sheet.
rows : int
    The number of rows in the sprite sheet.
delays : list of float
    A list of delays for each frame in seconds. This is also used to
    know how many frames there are.
loop : bool
    Whether the animation should loop. Default is True.
repeats : int
    The number of times to repeat the animation. 0 means infinite.
    This overrides loop if greater than 0. Default is 0.
anim_timebase : bool
    Whether to use the animation timebase (True) or the shown timebase.
hold_last_frame : bool
    For non-looping animations, whether to hold the last frame when done.

For example, a standard declaration of one of the included raindrop sheets is

image wet_drop_anim = BasicSheetAnim("michael_dashow_wet_drop", 1, 6, [0.04]*6, loop=False)

This makes an animation out of the provided sheet. It has 1 column and 6 rows. Each frame should be played for 0.04 seconds, so [0.04]*6 gives us [0.04, 0.04, 0.04, 0.04, 0.04, 0.04] for the delays. It should not loop.

## Recoloring

Many of the leaves provided have grayscale images suitable for recolouring with my colorize tool (https://feniksdev.itch.io/colorize-tool-for-renpy) or with matrixcolor. I suggest the following thresholds for the various leaves:

### BIGEISHE LEAVES

beech_1_4 - suggested thresholds: [255, 117, 0]
beech_2_4 - suggested thresholds: [229, 124, 0]
beech_3_4 - suggested thresholds: [248, 118, 0]
beech_4_4 - suggested thresholds: [255, 115, 0]

oak_1_4 - suggested thresholds: [228, 152, 0]
oak_2_4 - suggested thresholds: [253, 145, 0]
oak_3_4 - suggested thresholds: [255, 135, 0]
oak_4_4 - suggested thresholds: [225, 140, 0]

japanese_maple_1_4 - suggested thresholds: [255, 130, 0]
japanese_maple_2_4 - suggested thresholds: [255, 159, 0]
japanese_maple_3_4 - suggested thresholds: [255, 135, 0]
japanese_maple_4_4 - suggested thresholds: [218, 121, 0]

### KIGYODEV LEAVES
1i - suggested thresholds: [132, 92, 0]
2i - suggested thresholds: [132, 78, 0]
3i - suggested thresholds: [140, 78, 0]
4i - suggested thresholds: [134, 64, 0]
5i - suggested thresholds: [134, 64, 0]
6i - suggested thresholds: [134, 64, 0]
7i - suggested thresholds: [147, 64, 0]
8i - suggested thresholds: [149, 78, 0]
9i - suggested thresholds: [145, 76, 0]
10i - suggested thresholds: [145, 76, 0]
11i - suggested thresholds: [155, 76, 0]

### NPCKC LEAVES
Can simply be recoloured with ColorizeMatrix/black and white.

## Credit

The assets which come with this tool are licensed under CC-BY. This means they can be freely used in commercial and noncommercial projects with attribution. A license and attribution guide is included with each asset set. The code is released under an MIT license, included with the code in the libs/ subfolder. Attribution for the code should be credited as Feniks (https://feniksdev.com/).