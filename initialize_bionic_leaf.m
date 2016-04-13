function [ai, relayboxes] = initialize_bionic_leaf()

%Add analog device (USB-1616FS) with ID=1.
ai=analoginput('mcc',1);
%Add channel, USB1616FS has 16 differential channels (0...15)
channels=addchannel(ai,0:1);
%Set sampling rate to 1Khz
set(ai,'SampleRate',100)