using NAudio.Wave;
using System;
using System.Collections.Concurrent;
using System.Linq;
using System.Text.RegularExpressions;

namespace CallerCallee.Services
{
    public sealed class AudioPlayerService
    {
        private struct InternalPlayer(ref WaveOutEvent WaveOutEvent, ref AudioFileReader AudioFileReader)
        {
            public WaveOutEvent waveOutEvent = WaveOutEvent;
            public AudioFileReader audioFileReader = AudioFileReader;
        }

        private readonly ConcurrentDictionary<int, InternalPlayer> playingAudios = new();
        private readonly ConcurrentStack<int> availableDevices = new();

        public AudioPlayerService() {
            Regex regex = new Regex(@"CABLE-[A-D] In", RegexOptions.Compiled);

            Enumerable
                .Range(0, WaveOut.DeviceCount)
                .Where(i => regex.IsMatch(WaveOut.GetCapabilities(i).ProductName))
                .ToList()
                .ForEach(availableDevices.Push);
        }

        public int GetAvailableDevice()
        {
            var succeeded = availableDevices.TryPop(out int deviceNumber);
            if (succeeded)
            {
                return deviceNumber;
            }
            else
            {
                return -2; // -1 meaning "default device", which isnt what we want
                // -2 meaning there is available device at the moment
            }
        }

        public void PlayAudioFile(int deviceToPlayOn, string audioFilePath, EventHandler<StoppedEventArgs> eventHandler)
        {
            var outputDevice = new WaveOutEvent() { DeviceNumber = deviceToPlayOn };
            outputDevice.PlaybackStopped += eventHandler;
            var audioFile = new AudioFileReader(@audioFilePath);
            outputDevice.Init(audioFile);
            playingAudios[deviceToPlayOn] = new (ref outputDevice, ref audioFile);
            outputDevice.Play();
        }

        public bool TryFreeDevice(int deviceNumber) 
        {
            var succeeded = playingAudios.TryRemove(deviceNumber, out InternalPlayer internalPlayer);
            if (succeeded)
            {
                internalPlayer.waveOutEvent.Dispose();
                internalPlayer.audioFileReader.Dispose();
                availableDevices.Push(deviceNumber);
            }

            return succeeded;

        }
    }
}
