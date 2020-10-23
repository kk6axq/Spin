import time
import board
from digitalio import DigitalInOut, Direction, Pull
from adafruit_hid.consumer_control import ConsumerControl
from adafruit_hid.consumer_control_code import ConsumerControlCode
import usb_hid
import rotaryio

consumer_control = ConsumerControl(usb_hid.devices)

encoder = rotaryio.IncrementalEncoder(board.D3, board.D4)

led = DigitalInOut(board.D1)
led.direction = Direction.OUTPUT

switch = DigitalInOut(board.D2)
switch.direction = Direction.INPUT
switch.pull = Pull.UP

led.value=True
time.sleep(0.5)
led.value=False

p_enc_pos = 0
p_enc_time = 0
multi = False
multi_count = 0
repeat_thresh = 0.04
start_time = 0

while True:
    #This is a really hacky way to do it
    #but other methods didn't work...
    if switch.value == False:
        print("Start")
        time.sleep(0.3)
        if switch.value == False:
            time.sleep(0.3)
            if switch.value == True:
                consumer_control.send(ConsumerControlCode.PLAY_PAUSE)
        else:
            consumer_control.send(ConsumerControlCode.MUTE)

    if encoder.position != p_enc_pos:
        start_time = time.monotonic()
        delta_t = start_time - p_enc_time
        print(int(delta_t * 100))
        #Checks if time between ticks is less than threshold
        if delta_t < repeat_thresh:
            multi = True
        #Can multi-click up to 4 times depending on how fast it ticks
        multi_count = (repeat_thresh * 100) - int(delta_t * 100)
        #Change the < to > here if it's incrementing in the wrong direction
        if encoder.position < p_enc_pos:
            if multi:
                for i in range(multi_count):
                    consumer_control.send(ConsumerControlCode.VOLUME_INCREMENT)
                    print("Multi Increment")
            else:
                consumer_control.send(ConsumerControlCode.VOLUME_INCREMENT)
                print("Single Increment")
        else:
            if multi:
                for i in range(multi_count):
                    consumer_control.send(ConsumerControlCode.VOLUME_DECREMENT)
                    print("Multi Decrement")
            else:
                 consumer_control.send(ConsumerControlCode.VOLUME_DECREMENT)
                 print("Single Decrement")
        p_enc_pos = encoder.position
        p_enc_time = start_time
        multi = False
