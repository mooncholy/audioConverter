% Name: Mennatallah Yousri
% ID: 19106001

% Clear workspace
clc;
close all;
clear all;

% Read the audio file
filename = input("Enter file path between single quatations ''\nMono: 'mono_sound.mp3\nStereo: 'stereo_sound.mp3'\nDolby: 'ac3.ac3'\nOr input full path of your desired file\n");
if ismember(filename(end), {'/','\'})
    filename = filename(1:end-1);
end
ext = filename(end-2:end);
[audioData, Fs] = audioread(filename);
nSamples = size(audioData);
t = 0:999;

% Check if audio is already mono or stereo
numChannels = size(audioData, 2);

% Convert to Mono (if stereo or dolby)
if numChannels == 1
    % 1. Mono -> Stereo
    stereoData = repmat(audioData(:), 1, 2);
    panned_stereo = [0.6*stereoData(:,1) 0.4*stereoData(:,2)];
    audiowrite('./mono-to-stereo.wav', stereoData, Fs);
    fullpath1 = fullfile(pwd, 'mono-to-stereo.wav');
    fprintf('File [mono-to-stereo.wav] is successfully saved at %s\n', fullpath1);
    audiowrite('./panned_mono-to-stereo.wav', panned_stereo, Fs);
    fullpath2 = fullfile(pwd, 'panned_mono-to-stereo.wav');
    fprintf('File [panned_mono-to-stereo.wav] is successfully saved at %s\n', fullpath2);

    % 2. Mono -> Dolby
    mono_to_dolby = [0.4*panned_stereo(:,1) 0.3*audioData 0.3*panned_stereo(:,2)];
    audiowrite('./mono-to-dolby.wav', mono_to_dolby, Fs);
    fullpath3 = fullfile(pwd, 'mono-to-dolby.wav');
    fprintf('File [mono-to-dolby.wav] is successfully saved at %s\n', fullpath3);

    % Plot the signals
    % 1. Mono -> Stereo
    figure('Name', 'Mono-to-Stereo Conversion')
    sgtitle("Mono-to-Stereo Conversion")
    subplot(3,1,1)
    plot(t, audioData(1:1000,1))
    title("Mono Input Signal")
    xlabel('samples')
    ylabel('voltage')
    subplot(3,1,2)
    hold on;
    plot(t,stereoData(1:1000,1), 'k--*')
    plot(t,stereoData(1:1000,2))
    hold off;
    title("Stereo Generated Signal (Duplicate Channel)")
    legend('Left Channel', 'Right Channel')
    xlabel('samples')
    ylabel('voltage')
    subplot(3,1,3)
    hold on;
    plot(t,panned_stereo(1:1000,1))
    plot(t,panned_stereo(1:1000,2))
    hold off;
    title("Stereo Generated Signal (Pan 60%-40%)")
    legend('Left Channel', 'Right Channel')
    xlabel('samples')
    ylabel('voltage')

    figure('Name', 'Mono to Dolby Conversion')
    sgtitle("Mono-to-Dolby Conversion")
    subplot(2,1,1)
    plot(t, audioData(1:1000,1))
    title("Mono Input Signal")
    xlabel('samples')
    ylabel('voltage')
    subplot(2,1,2)
    for c = 1:3
        hold on;
        plot(t,mono_to_dolby(1:1000,c))
    end
    title('Dolby Generated Signal')
    xlabel('samples')
    ylabel('voltage')

elseif numChannels > 1 % Stereo or Dolby
    % 1. Stereo/Dolby - Mono
    monoData = mean(audioData,2);
    audiowrite('./mono_audio.wav', monoData, Fs);
    fullpath = fullfile(pwd, 'mono_audio.wav');
    fprintf('File [mono_audio.wav] is successfully saved at %s\n', fullpath);

    % Plot the signals
    % 1. Stereo/Dolby -> Mono
    figure('Name', 'Stereo/Dolby to Mono Conversion')
    sgtitle("N-channel-to-Mono Conversion")
    subplot(2,1,2)
    plot(t, monoData(1:1000,1))
    title("Mono Generated Signal")
    xlabel('samples')
    ylabel('voltage')
    subplot(2,1,1)
    for c = 1:numChannels
        hold on;
        plot(t,audioData(1:1000,c))
    end
    title("N-channel Input Signal")
    xlabel('samples')
    ylabel('voltage')
    % 2. Dolby -> Stereo
    if ext == "ac3" || numChannels > 2
        left_range = mean(audioData(:,1:floor(numChannels/2)),2);
        right_range = mean(audioData(:,floor(numChannels/2)+1:numChannels),2);
        stereo_audio = [left_range right_range];
        audiowrite('./dolby-to-stereo.wav', stereo_audio, Fs);
        fullpath1 = fullfile(pwd, 'dolby-to-stereo.wav');
        fprintf('File [dolby-to-stereo.wav] is successfully saved at %s\n', fullpath1);

        % Plot the signals
        figure('Name', 'Dolby to Stereo Conversion')
        sgtitle("Dolby-to-Stereo Conversion")
        subplot(2,1,1)
        for c = 1:numChannels
            hold on;
            plot(t,audioData(1:1000,c))
        end
        title('Dolby Input Signal')
        xlabel('samples')
        ylabel('voltage')
        subplot(2,1,2)
        hold on;
        plot(t, left_range(1:1000))
        plot(t, right_range(1:1000))
        hold off;
        title('Stereo Generated Signal')
        xlabel('samples')
        ylabel('voltage')
        legend('Left Channel', 'Right Channel')

    % 3. Stereo -> Dolby
    else
        dolby = [0.4*audioData(:,1) 0.3*monoData 0.3*audioData(:,2)];
        audiowrite('./stereo-to-dolby.wav', dolby, Fs);
        fullpath2 = fullfile(pwd, 'stereo-to-dolby.wav');
        fprintf('File [stereo-to-dolby.wav] is successfully saved at %s\n', fullpath2);

        % Plot the signals
        figure('Name', 'Stereo to Dolby Conversion')
        sgtitle('Stereo-to-Dolby Conversion')
        subplot(2,1,1)
        hold on;
        plot(t,audioData(1:1000,1))
        plot(t,audioData(1:1000,2))
        hold off;
        title("2-channel Input Signal")
        subplot(2,1,2)
        hold on;
        plot(t,dolby(1:1000,1))
        plot(t,dolby(1:1000,2))
        plot(t,dolby(1:1000,3))
        hold off;
        title('3-Channel Dolby simulator (40%-30%-30%)')
        legend("left channel", "center channel", "right channel")
    end
else
    disp("Corrupt audio file")
end
